//
//  bridge.cpp
//  Grape
//
//  Created by Jarrod Norwell on 28/6/2026.
//

#include "melonDS/bridge.h"
#include "frontend/LAN_Socket.h"
#include "melonDS/Config.h"
#include "melonDS/Platform.h"
#include "melonDS/NDS.h"
#include "melonDS/SPU.h"
#include "melonDS/GPU.h"
#include "melonDS/AREngine.h"

#include "Grape-Swift.h"
using namespace Grape;

#define SDL_MAIN_HANDLED
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include <_printf.h>
#include <algorithm>
#include <condition_variable>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <memory>
#include <vector>

// MARK: NDS Icon
#define U8TO16(data, index) ((data)[index] | ((data)[(index) + 1] << 8))
#define U8TO32(data, index) ((data)[index] | ((data)[(index) + 1] << 8) | ((data)[(index) + 2] << 16) | ((data)[(index) + 3] << 24))
#define U8TO64(data, index) ((uint64_t)U8TO32(data, (index) + 4) << 32) | (uint32_t)U8TO32(data, index)

class NDSIcon
{
public:
    NDSIcon(std::filesystem::path path) {
        buffer = new uint32_t[32 * 32];
        memset(buffer, 0, 32 * 32 * sizeof(uint32_t));
        
        auto disc = fopen(path.c_str(), "rb");
        if (disc == nullptr)
            return;
        
        uint8_t icon_offset[0x04];
        fseek(disc, 0x68, SEEK_SET);
        fread(icon_offset, sizeof(uint8_t), 0x04, disc);
        // if (icon_offset == 0x00)
        //     return;
        
        uint8_t icon_data[0x200];
        fseek(disc, U8TO32(icon_offset, 0) + 0x20, SEEK_SET);
        fread(icon_data, sizeof(uint8_t), 0x200, disc);
        
        uint8_t icon_palette[0x20];
        fseek(disc, U8TO32(icon_offset, 0) + 0x220, SEEK_SET);
        fread(icon_palette, sizeof(uint8_t), 0x20, disc);
        
        fclose(disc);
        
        uint32_t tiles[32 * 32];
        for (int i = 0; i < 32 * 32; i++) {
            uint8_t index = (i & 1) ? ((icon_data[i / 2] & 0xF0) >> 4) : (icon_data[i / 2] & 0x0F);
            
            uint16_t color = index ? U8TO16(icon_palette, index * 2) : 0xFFFF;
            
            uint8_t r = ((color >>  0) & 0x1F) * 255 / 31;
            uint8_t g = ((color >>  5) & 0x1F) * 255 / 31;
            uint8_t b = ((color >> 10) & 0x1F) * 255 / 31;
            
            tiles[i] = (0xFF << 24) | (b << 16) | (g << 8) | r;
        }
        
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 8; j++) {
                for (int k = 0; k < 4; k++)
                    memcpy(&buffer[256 * i + 32 * j + 8 * k], &tiles[256 * i + 8 * j + 64 * k], 8 * sizeof(uint32_t));
            }
        }
    };
    
    uint32_t *icon_buffer() {
        return buffer;
    }
private:
    uint32_t* buffer;
};

struct CPPGrape {
    SDL_AudioDeviceID device{0};
    SDL_AudioStream* stream{nullptr};
    
    std::jthread thread;
    std::atomic<bool> paused, running;
    std::mutex mutex;
    std::condition_variable_any cv;
    uint32_t inputs;
    
    std::filesystem::path grape_path, save_states_path, system_data_path;
    std::filesystem::path save_file_url;
    std::string file_name_without_extension;
} cppGrape;

enum ConsoleType : int {
    DS = 0,
    DSi = 1
};

void grape::print_about(void) {
    printf("Welcome to Grape\n");
    printf("Nintendo DS emulator based on melonDS\n");
    printf("Grape Directory: %s\n", [GrapeCommon.grapeDirectoryURL.path cStringUsingEncoding:NSUTF8StringEncoding]);
}

uint32_t* grape::icon_from_disc(std::string path) {
    auto disc_path{std::filesystem::path{path}};
    NDSIcon icon{disc_path};
    return icon.icon_buffer();
}

void grape::initialize_paths(void) {
    auto grapeDirectoryURL{std::filesystem::path{[GrapeCommon.grapeDirectoryURL.path cStringUsingEncoding:NSUTF8StringEncoding]}};
    if (std::filesystem::exists(grapeDirectoryURL)) {
        auto grape_path{grapeDirectoryURL};
        
        cppGrape.grape_path = grape_path;
        cppGrape.save_states_path = grape_path / "save_states";
        cppGrape.system_data_path = grape_path / "system_data";
    }
}

void grape::initialize_system(void) {
    Config::Load();
    GPU::InitRenderer(0);
    
    NSURL *systemDataDirectory = [GrapeCommon.grapeDirectoryURL URLByAppendingPathComponent:@"system_data"];
    
    Config::BIOS7Path = [[systemDataDirectory URLByAppendingPathComponent:@"bios7.bin"].path UTF8String];
    Config::BIOS9Path = [[systemDataDirectory URLByAppendingPathComponent:@"bios9.bin"].path UTF8String];
    Config::FirmwarePath = [[systemDataDirectory URLByAppendingPathComponent:@"firmware.bin"].path UTF8String];
    
    Config::DirectBoot = Config::ExternalBIOSEnable = true;
    
    BOOL (^fileExists)(NSURL *) = ^BOOL(NSURL *url) {
        return [[NSFileManager defaultManager] fileExistsAtPath:url.path];
    };
    
    NSURL *bios7i = [systemDataDirectory URLByAppendingPathComponent:@"bios7i.bin"];
    NSURL *bios9i = [systemDataDirectory URLByAppendingPathComponent:@"bios9i.bin"];
    NSURL *firmwarei = [systemDataDirectory URLByAppendingPathComponent:@"firmwarei.bin"];
    NSURL *nandi = [systemDataDirectory URLByAppendingPathComponent:@"nandi.bin"];
    
    if (fileExists(bios7i) && fileExists(bios9i) && fileExists(firmwarei) && fileExists(nandi)) {
        NDS::SetConsoleType(ConsoleType::DSi);
        
        Config::DSiBIOS7Path = [bios7i.path UTF8String];
        Config::DSiBIOS9Path = [bios9i.path UTF8String];
        Config::DSiFirmwarePath = [firmwarei.path UTF8String];
        Config::DSiNANDPath = [nandi.path UTF8String];
    } else
        NDS::SetConsoleType(ConsoleType::DS);
    
    cppGrape.inputs = 0;
}

void grape::destroy_system(void) {
    NDS::Init();
    
    GPU::RenderSettings settings;
    settings.Soft_Threaded = true;
    
    GPU::SetRenderSettings(0, settings);
    
    NDS::Reset();
}

void grape::insert_disc(std::string path) {
    grape::destroy_system();
    
    NSString *string = [NSString stringWithCString:path.c_str() encoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithContentsOfFile:string];
    
    NSURL *url = [NSURL URLWithString:string];
    
    cppGrape.file_name_without_extension = [[[url URLByDeletingPathExtension] lastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding];
    cppGrape.save_file_url = cppGrape.save_states_path / cppGrape.file_name_without_extension.append(".save");
    
    u32 save_length{0};
    u8* save_data{nullptr};
    
    FILE* file = std::fopen(cppGrape.save_file_url.c_str(), "rb");
    if (file) {
        std::fseek(file, 0, SEEK_END);
        save_length = (u32)std::ftell(file);
        
        std::fseek(file, 0, SEEK_SET);
        save_data = new u8[save_length];
        std::fread(save_data, save_length, 1, file);
        std::fclose(file);
    }
    
    NDS::LoadCart((const u8*)data.bytes, (u32)data.length, save_data, save_length);
    if (Config::DirectBoot)
        NDS::SetupDirectBoot(path);
    
    NDS::Start();
    
    SDL_SetMainReady();
    SDL_InitSubSystem(SDL_INIT_AUDIO);
    
    SDL_AudioSpec spec;
    SDL_zero(spec);
    spec.format = SDL_AUDIO_S16;
    spec.channels = 2;
    spec.freq = 32768;
    
    cppGrape.device = SDL_OpenAudioDevice(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &spec);
    cppGrape.stream = SDL_OpenAudioDeviceStream(cppGrape.device, &spec, [](void* data, SDL_AudioStream* stream, int add, int total) {
        (void)data;
        
        if (add <= 0)
            return;
        
        std::vector<s16> buf(0x1000);
        std::fill(buf.begin(), buf.end(), 0);
        
        u32 availableBytes = SPU::GetOutputSize();
        availableBytes = MAX(availableBytes, (u32)(buf.size() / (2 * sizeof(int16_t))));
        
        int samples = SPU::ReadOutput(buf.data(), availableBytes);
        
        SDL_PutAudioStreamData(stream, buf.data(), samples * 4);
    }, nil);
    SDL_ResumeAudioStreamDevice(cppGrape.stream);
}

bool grape::is_paused(bool change, bool set_paused) {
    if (change)
        cppGrape.paused.store(set_paused);
    if (!set_paused)
        cppGrape.cv.notify_all();
    return cppGrape.paused.load();
}

bool grape::is_running(bool change, bool set_running) {
    if (change)
        cppGrape.running.store(set_running);
    return cppGrape.running.load();
}

void grape::start(void) {
    cppGrape.thread = std::jthread([&](std::stop_token token) {
        using namespace std::chrono;
        
        const auto frameDuration = duration<double>(1.0 / 60.0);
        
        while (!token.stop_requested()) {
            {
                std::unique_lock lock(cppGrape.mutex);
                cppGrape.cv.wait(lock, token, []() {
                    return !cppGrape.paused.load();
                });
                
                if (token.stop_requested())
                    break;
            }
            
            auto frameStart = steady_clock::now();
            
            uint32_t _inputs = cppGrape.inputs;
            uint32_t inputsMask = 0xFFF;
            
            uint16_t sanitizedInputs = inputsMask ^ _inputs;
            NDS::SetKeyMask(sanitizedInputs);
            
            NDS::RunFrame();
            
            grape::callback(grape::context, GPU::Framebuffer[GPU::FrontBuffer][0], GPU::Framebuffer[GPU::FrontBuffer][1]);
            
            // Limit FPS
            auto frameEnd = steady_clock::now();
            auto elapsed = frameEnd - frameStart;
            if (elapsed < frameDuration)
                std::this_thread::sleep_for(frameDuration - elapsed);
        }
    });
}

void grape::stop(void) {
    NDS::Stop();
    NDS::DeInit();
    
    cppGrape.thread.request_stop();
    if (cppGrape.thread.joinable())
        cppGrape.thread.join();
    
    cppGrape.paused.store(false);
    cppGrape.running.store(false);
}

int grape::framebuffer_height(void) {
    return 192;
}

int grape::framebuffer_width(void) {
    return 256;
}

void grape::video_buffer_callback(grape::VideoBufferCallback callback) {
    grape::callback = callback;
}

void grape::press_button(uint32_t button) {
    cppGrape.inputs |= button;
}

void grape::release_button(uint32_t button) {
    cppGrape.inputs &= ~button;
}

void grape::touch_began(uint16_t x, uint16_t y) {
    NDS::TouchScreen(x, y);
}

void grape::touch_ended(void) {
    NDS::ReleaseScreen();
}

void grape::touch_moved(uint16_t x, uint16_t y) {
    NDS::TouchScreen(x, y);
}

void grape::set_context(void* context) {
    grape::context = context;
}



// MARK: Platform
namespace Platform
{
int IPCInstanceID;

void StopEmu() {}

int InstanceID()
{
    return IPCInstanceID;
}

std::string InstanceFileSuffix()
{
    int inst = IPCInstanceID;
    if (inst == 0) return "";
    
    char suffix[16] = {0};
    snprintf(suffix, 15, ".%d", inst+1);
    return suffix;
}

int GetConfigInt(ConfigEntry entry)
{
    const int imgsizes[] = {0, 256, 512, 1024, 2048, 4096};
    
    switch (entry)
    {
        default: break;
#ifdef JIT_ENABLED
        case JIT_MaxBlockSize: return Config::JIT_MaxBlockSize;
#endif
            
        case DLDI_ImageSize: return imgsizes[Config::DLDISize];
            
        case DSiSD_ImageSize: return imgsizes[Config::DSiSDSize];
            
        case Firm_Language: return Config::FirmwareLanguage;
        case Firm_BirthdayMonth: return Config::FirmwareBirthdayMonth;
        case Firm_BirthdayDay: return Config::FirmwareBirthdayDay;
        case Firm_Color: return Config::FirmwareFavouriteColour;
            
        case AudioBitrate: return Config::AudioBitrate;
    }
    
    return 0;
}

bool GetConfigBool(ConfigEntry entry)
{
    switch (entry)
    {
        default: break;
#ifdef JIT_ENABLED
        case JIT_Enable: return Config::JIT_Enable != 0;
        case JIT_LiteralOptimizations: return Config::JIT_LiteralOptimisations != 0;
        case JIT_BranchOptimizations: return Config::JIT_BranchOptimisations != 0;
        case JIT_FastMemory: return Config::JIT_FastMemory != 0;
#endif
            
        case ExternalBIOSEnable: return Config::ExternalBIOSEnable != 0;
            
        case DLDI_Enable: return Config::DLDIEnable != 0;
        case DLDI_ReadOnly: return Config::DLDIReadOnly != 0;
        case DLDI_FolderSync: return Config::DLDIFolderSync != 0;
            
        case DSiSD_Enable: return Config::DSiSDEnable != 0;
        case DSiSD_ReadOnly: return Config::DSiSDReadOnly != 0;
        case DSiSD_FolderSync: return Config::DSiSDFolderSync != 0;
            
        case Firm_OverrideSettings: return Config::FirmwareOverrideSettings != 0;
    }
    
    return false;
}

std::string GetConfigString(ConfigEntry entry)
{
    switch (entry)
    {
        default: break;
        case BIOS9Path: return Config::BIOS9Path;
        case BIOS7Path: return Config::BIOS7Path;
        case FirmwarePath: return Config::FirmwarePath;
            
        case DSi_BIOS9Path: return Config::DSiBIOS9Path;
        case DSi_BIOS7Path: return Config::DSiBIOS7Path;
        case DSi_FirmwarePath: return Config::DSiFirmwarePath;
        case DSi_NANDPath: return Config::DSiNANDPath;
            
        case DLDI_ImagePath: return Config::DLDISDPath;
        case DLDI_FolderPath: return Config::DLDIFolderPath;
            
        case DSiSD_ImagePath: return Config::DSiSDPath;
        case DSiSD_FolderPath: return Config::DSiSDFolderPath;
            
        case Firm_Username: return Config::FirmwareUsername;
        case Firm_Message: return Config::FirmwareMessage;
    }
    
    return "";
}

bool GetConfigArray(ConfigEntry entry, void* data)
{
    switch (entry)
    {
        default: break;
        case Firm_MAC:
        {
            std::string& mac_in = Config::FirmwareMAC;
            u8* mac_out = (u8*)data;
            
            int o = 0;
            u8 tmp = 0;
            for (int i = 0; i < 18; i++)
            {
                char c = mac_in[i];
                if (c == '\0') break;
                
                int n;
                if      (c >= '0' && c <= '9') n = c - '0';
                else if (c >= 'a' && c <= 'f') n = c - 'a' + 10;
                else if (c >= 'A' && c <= 'F') n = c - 'A' + 10;
                else continue;
                
                if (!(o & 1))
                    tmp = n;
                else
                    mac_out[o >> 1] = n | (tmp << 4);
                
                o++;
                if (o >= 12) return true;
            }
        }
            return false;
    }
    
    return false;
}

FILE* OpenFile(std::string path, std::string mode, bool mustexist)
{
    FILE* ret;
    
    if (mustexist)
    {
        ret = fopen(path.c_str(), "rb");
        if (ret) ret = freopen(path.c_str(), mode.c_str(), ret);
    }
    else
        ret = fopen(path.c_str(), mode.c_str());
    
    return ret;
}

FILE* OpenLocalFile(std::string path, std::string mode)
{
    NSURL *relativeURL = [GrapeCommon.grapeDirectoryURL URLByAppendingPathComponent:@(path.c_str())];
    
    NSURL *fileURL = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:relativeURL.path] || path.find(".bak") != std::string::npos)
    {
        fileURL = relativeURL;
    }
    else
    {
        if (path.find("wfcsettings") != std::string::npos)
            fileURL = [[GrapeCommon.grapeDirectoryURL URLByAppendingPathComponent:@"system_data"] URLByAppendingPathComponent:@(path.c_str())];
        else
            fileURL = [NSURL fileURLWithPath:@(path.c_str())];
    }
    
    return OpenFile(fileURL.fileSystemRepresentation, mode.c_str());
}

Thread* Thread_Create(std::function<void()> func)
{
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        func();
    }];
    
    thread.name = @"melonDS - Rendering";
    thread.qualityOfService = NSQualityOfServiceUserInitiated;
    
    [thread start];
    
    return (Thread *)CFBridgingRetain(thread);
}

void Thread_Free(Thread *thread)
{
    NSThread *nsThread = (NSThread *)CFBridgingRelease(thread);
    [nsThread cancel];
}

void Thread_Wait(Thread *thread)
{
    NSThread *nsThread = (__bridge NSThread *)thread;
    while (nsThread.isExecuting)
    {
        continue;
    }
}

Semaphore *Semaphore_Create()
{
    dispatch_semaphore_t dispatchSemaphore = dispatch_semaphore_create(0);
    return (Semaphore *)CFBridgingRetain(dispatchSemaphore);
}

void Semaphore_Free(Semaphore *semaphore)
{
    CFRelease(semaphore);
}

void Semaphore_Reset(Semaphore *semaphore)
{
    dispatch_semaphore_t dispatchSemaphore = (__bridge dispatch_semaphore_t)semaphore;
    while (dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_NOW) == 0)
    {
        continue;
    }
}

void Semaphore_Wait(Semaphore *semaphore)
{
    dispatch_semaphore_t dispatchSemaphore = (__bridge dispatch_semaphore_t)semaphore;
    dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_FOREVER);
}

void Semaphore_Post(Semaphore *semaphore, int count)
{
    dispatch_semaphore_t dispatchSemaphore = (__bridge dispatch_semaphore_t)semaphore;
    for (int i = 0; i < count; i++)
    {
        dispatch_semaphore_signal(dispatchSemaphore);
    }
}

Mutex *Mutex_Create()
{
    // NSLock is too slow for real-time audio, so use pthread_mutex_t directly.
    
    pthread_mutex_t *mutex = (pthread_mutex_t *)malloc(sizeof(pthread_mutex_t));
    pthread_mutex_init(mutex, NULL);
    return (Mutex *)mutex;
}

void Mutex_Free(Mutex *m)
{
    pthread_mutex_t *mutex = (pthread_mutex_t *)m;
    pthread_mutex_destroy(mutex);
    free(mutex);
}

void Mutex_Lock(Mutex *m)
{
    pthread_mutex_t *mutex = (pthread_mutex_t *)m;
    pthread_mutex_lock(mutex);
}

void Mutex_Unlock(Mutex *m)
{
    pthread_mutex_t *mutex = (pthread_mutex_t *)m;
    pthread_mutex_unlock(mutex);
}

void *GL_GetProcAddress(const char* proc)
{
    return NULL;
}

bool MP_Init()
{
    return false;
}

void MP_DeInit()
{
}

void MP_Begin()
{
}

void MP_End()
{
}

int MP_SendPacket(u8* data, int len, u64 timestamp)
{
    return 0;
}

int MP_RecvPacket(u8* data, u64* timestamp)
{
    return 0;
}

int MP_SendCmd(u8* data, int len, u64 timestamp)
{
    return 0;
}

int MP_SendReply(u8* data, int len, u64 timestamp, u16 aid)
{
    return 0;
}

int MP_SendAck(u8* data, int len, u64 timestamp)
{
    return 0;
}

int MP_RecvHostPacket(u8* data, u64* timestamp)
{
    return 0;
}

u16 MP_RecvReplies(u8* data, u64 timestamp, u16 aidmask)
{
    return 0;
}

bool LAN_Init() {
    if (!LAN_Socket::Init())
        return false;
    return true;
}

void LAN_DeInit()
{
    LAN_Socket::DeInit();
}

int LAN_SendPacket(u8* data, int len)
{
    return LAN_Socket::SendPacket(data, len);
}

int LAN_RecvPacket(u8* data)
{
    return LAN_Socket::RecvPacket(data);
}

void Mic_Prepare()
{
    //if (![MelonDSEmulatorBridge.sharedBridge isMicrophoneEnabled] || [MelonDSEmulatorBridge.sharedBridge.audioEngine isRunning])
    //{
    //    return;
    //}
    
    //NSError *error = nil;
    //if (![MelonDSEmulatorBridge.sharedBridge.audioEngine startAndReturnError:&error])
    //{
    //    NSLog(@"Failed to start listening to microphone. %@", error);
    //}
}

void WriteNDSSave(const u8* savebytes, u32 savelen, u32 writeoffset, u32 writelen) {
    [[NSData dataWithBytes:savebytes length:savelen] writeToFile:[NSString stringWithCString:cppGrape.save_file_url.c_str() encoding:NSUTF8StringEncoding] atomically:YES];
}

void WriteGBASave(const u8* savebytes, u32 savelen, u32 writeoffset, u32 writelen) {
    [[NSData dataWithBytes:savebytes length:savelen] writeToFile:[NSString stringWithCString:cppGrape.save_file_url.c_str() encoding:NSUTF8StringEncoding] atomically:YES];
}

void Camera_Start(int num)
{
    
}

void Camera_Stop(int num)
{
    
}

void Camera_CaptureFrame(int num, u32* frame, int width, int height, bool yuv)
{
    
}
}
