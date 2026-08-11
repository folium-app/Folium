//
//  bridge.cpp
//  Cherry
//
//  Created by Jarrod Norwell on 9/8/2026.
//

#include "gearcoleco/bridge.h"
#include "gearcoleco/CVMemory.h"
#include "gearcoleco/GearcolecoCore.h"

#import "Cherry-Swift.h"
#import <AudioUnit/AudioUnit.h>
using namespace Cherry;

#include <condition_variable>
#include <filesystem>
#include <mutex>
#include <thread>

class SoundQueue {
public:
    SoundQueue();
    ~SoundQueue();

    bool Start(int sample_rate, int channel_count, int buffer_size, int buffer_count);
    void Stop();

    void Write(int16_t* samples, int count, bool sync);
    int GetSampleCount();
    bool IsOpen();
    int16_t* GetCurrentlyPlaying();

private:
    static OSStatus RenderCallback(void* inRefCon,
                                   AudioUnitRenderActionFlags* ioActionFlags,
                                   const AudioTimeStamp* inTimeStamp,
                                   UInt32 inBusNumber,
                                   UInt32 inNumberFrames,
                                   AudioBufferList* ioData);

    void FillBuffer(uint8_t* buffer, int byteCount);

    int16_t* Buffer(int index) {
        return m_buffers + (index * m_buffer_size);
    }

private:
    AudioUnit m_audioUnit = nullptr;

    int16_t* m_buffers = nullptr;
    int16_t* m_currently_playing = nullptr;

    dispatch_semaphore_t m_free_sem = nullptr;

    int m_buffer_size = 0;
    int m_buffer_count = 0;

    int m_write_buffer = 0;
    int m_write_position = 0;
    int m_read_buffer = 0;

    bool m_sound_open = false;
    bool m_sync_output = true;
};

SoundQueue::SoundQueue()
{
    m_buffers = nullptr;
    m_free_sem = nullptr;
    m_sound_open = false;
}

SoundQueue::~SoundQueue() {}

bool SoundQueue::Start(int sample_rate,
                       int channel_count,
                       int buffer_size,
                       int buffer_count)
{
    m_buffer_size  = buffer_size;
    m_buffer_count = buffer_count;

    m_buffers = new int16_t[m_buffer_size * m_buffer_count]();
    m_currently_playing = m_buffers;

    m_free_sem = dispatch_semaphore_create(m_buffer_count - 1);

    // Describe audio unit
    AudioComponentDescription desc = {};
    desc.componentType         = kAudioUnitType_Output;
#if TARGET_OS_IPHONE
    desc.componentSubType      = kAudioUnitSubType_RemoteIO;
#else
    desc.componentSubType      = kAudioUnitSubType_DefaultOutput;
#endif
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;

    AudioComponent comp = AudioComponentFindNext(nullptr, &desc);
    if (!comp) return false;

    if (AudioComponentInstanceNew(comp, &m_audioUnit) != noErr)
        return false;

    // Set format
    AudioStreamBasicDescription format = {};
    format.mSampleRate       = sample_rate;
    format.mFormatID         = kAudioFormatLinearPCM;
    format.mFormatFlags      = kAudioFormatFlagIsSignedInteger |
                               kAudioFormatFlagIsPacked;
    format.mBitsPerChannel   = 16;
    format.mChannelsPerFrame = channel_count;
    format.mFramesPerPacket  = 1;
    format.mBytesPerFrame    = 2 * channel_count;
    format.mBytesPerPacket   = format.mBytesPerFrame;

    AudioUnitSetProperty(m_audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &format,
                         sizeof(format));

    // Set callback
    AURenderCallbackStruct callback;
    callback.inputProc = RenderCallback;
    callback.inputProcRefCon = this;

    AudioUnitSetProperty(m_audioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         0,
                         &callback,
                         sizeof(callback));

    if (AudioUnitInitialize(m_audioUnit) != noErr)
        return false;

    if (AudioOutputUnitStart(m_audioUnit) != noErr)
        return false;

    m_sound_open = true;
    return true;
}

void SoundQueue::Stop()
{
    if (m_sound_open)
    {
        AudioOutputUnitStop(m_audioUnit);
        AudioUnitUninitialize(m_audioUnit);
        AudioComponentInstanceDispose(m_audioUnit);
        m_audioUnit = nullptr;
        m_sound_open = false;
    }

    if (m_free_sem)
    {
        m_free_sem = nullptr;
    }

    delete[] m_buffers;
    m_buffers = nullptr;
}

OSStatus SoundQueue::RenderCallback(void* inRefCon,
                                    AudioUnitRenderActionFlags*,
                                    const AudioTimeStamp*,
                                    UInt32,
                                    UInt32 inNumberFrames,
                                    AudioBufferList* ioData)
{
    SoundQueue* self = static_cast<SoundQueue*>(inRefCon);

    int byteCount = inNumberFrames *
                    ioData->mBuffers[0].mNumberChannels *
                    sizeof(int16_t);

    self->FillBuffer((uint8_t*)ioData->mBuffers[0].mData,
                     byteCount);

    return noErr;
}

void SoundQueue::FillBuffer(uint8_t* buffer, int count)
{
    bool has_data;

    if (m_sync_output)
        has_data = (dispatch_semaphore_wait(m_free_sem, DISPATCH_TIME_NOW) != 0);
    else
        has_data = (m_read_buffer != m_write_buffer);

    if (has_data)
    {
        m_currently_playing = Buffer(m_read_buffer);

        memcpy(buffer,
               Buffer(m_read_buffer),
               count);

        m_read_buffer =
            (m_read_buffer + 1) % m_buffer_count;

        if (m_sync_output)
            dispatch_semaphore_signal(m_free_sem);
    }
    else
    {
        memset(buffer, 0, count);
    }
}

void SoundQueue::Write(int16_t* samples,
                       int count,
                       bool sync)
{
    if (!m_sound_open)
        return;

    m_sync_output = sync;

    while (count)
    {
        int n = m_buffer_size - m_write_position;
        if (n > count) n = count;

        memcpy(Buffer(m_write_buffer) + m_write_position,
               samples,
               n * sizeof(int16_t));

        samples += n;
        m_write_position += n;
        count -= n;

        if (m_write_position >= m_buffer_size)
        {
            m_write_position = 0;

            if (m_sync_output)
            {
                m_write_buffer =
                    (m_write_buffer + 1) % m_buffer_count;

                dispatch_semaphore_wait(m_free_sem,
                                        DISPATCH_TIME_FOREVER);
            }
            else
            {
                int next =
                    (m_write_buffer + 1) % m_buffer_count;

                if (next != m_read_buffer)
                    m_write_buffer = next;
            }
        }
    }
}

struct CherryCPP {
    CherryCommon cherryCommon{CherryCommon::init()};
    CherrySystem cherrySystem{CherrySystem::init()};
    
    GearcolecoCore *system;
    SoundQueue* soundQueue;
    
    int16_t* ab;
    uint8_t* fb;
    
    std::filesystem::path cherry_path, system_data_path;
    
    std::jthread thread;
    std::mutex mutex;
    std::atomic<bool> paused, running;
    std::condition_variable_any cv;
} cherry_cntnr;

void cherry::print_about(void) {
    printf("Welcome to Cherry\n");
    printf("ColecoVision emulator based on Gearcoleco\n");
}

void cherry::initialize_paths(void) {
    auto cherryDirectoryURL{cherry_cntnr.cherryCommon.getCherryDirectoryURL()};
    if (cherryDirectoryURL.isSome()) {
        auto cherry_path{std::filesystem::path{cherryDirectoryURL.get()}};
        
        cherry_cntnr.cherry_path = cherry_path;
        cherry_cntnr.system_data_path = cherry_path / "system_data";
    }
}

void cherry::initialize_system(void) {
    auto bios_path = cherry_cntnr.system_data_path / "bios.col";
    
    cherry_cntnr.system = new GearcolecoCore;
    cherry_cntnr.system->Init();
    cherry_cntnr.system->GetMemory()->LoadBios(bios_path.c_str());
    
    cherry_cntnr.soundQueue = new SoundQueue;
    cherry_cntnr.soundQueue->Start(GC_AUDIO_SAMPLE_RATE, 2, 4096, 2);
    
    if (cherry_cntnr.ab)
        delete [] cherry_cntnr.ab;
    
    if (cherry_cntnr.fb)
        delete [] cherry_cntnr.fb;
    
    cherry_cntnr.ab = new int16_t[GC_AUDIO_BUFFER_SIZE];
    cherry_cntnr.fb = new uint8_t[GC_RESOLUTION_WIDTH * GC_RESOLUTION_HEIGHT * 3];
}

void cherry::destroy_system(void) {
    SafeDelete(cherry_cntnr.system);
    SafeDelete(cherry_cntnr.soundQueue);
    
    cherry::initialize_system();
}

void cherry::insert_disc(std::string path) {
    cherry::destroy_system();
    
    cherry_cntnr.system->SaveRam();
    cherry_cntnr.system->LoadROM(path.c_str());
    cherry_cntnr.system->LoadRam();
}

bool cherry::is_paused(bool change, bool set_paused) {
    if (change)
        cherry_cntnr.paused.store(set_paused);
    return cherry_cntnr.paused.load();
}

bool cherry::is_running(bool change, bool set_running) {
    if (change)
        cherry_cntnr.running.store(set_running);
    return cherry_cntnr.running.load();
}

void cherry::start(void) {
    cherry_cntnr.thread = std::jthread([&](std::stop_token token) {
        using namespace std::chrono;
        
        const auto frameDuration = duration<double>(1.0 / (cherry_cntnr.system->GetCartridge()->IsPAL() ? 50.0 : 60.0));

        while (!token.stop_requested()) {
            {
                std::unique_lock lock(cherry_cntnr.mutex);
                cherry_cntnr.cv.wait(lock, token, []() {
                    return !cherry_cntnr.paused.load();
                });
                
                if (token.stop_requested())
                    break;
            }
            
            auto frameStart = steady_clock::now();
            
            int samples = 0;
            cherry_cntnr.system->RunToVBlank(cherry_cntnr.fb, cherry_cntnr.ab, &samples);
            cherry::video_callback(cherry::context, cherry_cntnr.fb);
            
            if ((samples > 0) && !cherry_cntnr.paused.load())
                cherry_cntnr.soundQueue->Write(cherry_cntnr.ab, samples, true);

            // Limit FPS
            auto frameEnd = steady_clock::now();
            auto elapsed = frameEnd - frameStart;
            if (elapsed < frameDuration)
                std::this_thread::sleep_for(frameDuration - elapsed);
        }
    });
}

void cherry::stop(void) {
    cherry_cntnr.thread.request_stop();
    if (cherry_cntnr.thread.joinable())
        cherry_cntnr.thread.join();
    
    cherry_cntnr.paused.store(false);
    cherry_cntnr.running.store(false);
}

int cherry::framebuffer_height(void) {
    return 192;
}

int cherry::framebuffer_width(void) {
    return 256;
}

void cherry::video_buffer_callback(cherry::VideoBufferCallback callback) {
    cherry::video_callback = callback;
}

void cherry::press_button(int button, int index) {
    cherry_cntnr.system->KeyPressed(static_cast<GC_Controllers>(index), static_cast<GC_Keys>(button));
}

void cherry::release_button(int button, int index) {
    cherry_cntnr.system->KeyReleased(static_cast<GC_Controllers>(index), static_cast<GC_Keys>(button));
}

void cherry::set_context(void* context) {
    cherry::context = context;
}
