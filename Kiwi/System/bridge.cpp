//
//  bridge.cpp
//  Kiwi
//
//  Created by Jarrod Norwell on 2/7/2026.
//

#include "gambatte/bridge.h"

#include "gambatte/gambatte.h"
#include "gambatte/common/ringbuffer.h"
#include "gambatte/common/rateest.h"
#include "gambatte/common/resample/resampler.h"
#include "gambatte/common/resample/resamplerinfo.h"
#include "gambatte/common/scoped_ptr.h"

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <filesystem>
#include <mutex>
#include <thread>

#include "Kiwi-Swift.h"
using namespace Kiwi;

struct CPPKiwi {
    KiwiCommon kiwiCommon{KiwiCommon::init()};
    KiwiSystem kiwiSystem{KiwiSystem::init()};
    
    gambatte::GB gameboy{};
    
    uint32_t* fb{nullptr};
    uint32_t* ab{nullptr};
    
    std::condition_variable_any cv;
    std::mutex mutex;
    std::atomic<bool> paused, running;
    std::jthread thread;
    
    uint32_t activeInput[8];
    
    std::filesystem::path kiwi_path, save_states_path, system_data_path;
} cppKiwi;


class GetInput : public gambatte::InputGetter {
public:
    unsigned operator()() {
        return cppKiwi.activeInput[0];
    }
} static GetInput;


void kiwi::print_about(void) {
    printf("Welcome to Kiwi\n");
    printf("Game Boy emulator based on Gambatte\n");
}

void kiwi::initialize_paths(void) {
    auto kiwiDirectoryURL{cppKiwi.kiwiCommon.getKiwiDirectoryURL()};
    if (kiwiDirectoryURL.isSome()) {
        auto kiwi_path{std::filesystem::path{kiwiDirectoryURL.get()}};
        printf("%s\n", kiwi_path.string().c_str());
        
        cppKiwi.kiwi_path = kiwi_path;
        cppKiwi.save_states_path = kiwi_path / "save_states";
        cppKiwi.system_data_path = kiwi_path / "system_data";
    }
}

void kiwi::initialize_system(void) {
    if (cppKiwi.ab)
        delete [] cppKiwi.ab;
    
    if (cppKiwi.fb)
        delete [] cppKiwi.fb;
    
    cppKiwi.ab = new uint32_t[2064 * 2 * 4];
    cppKiwi.fb = new uint32_t[160 * 144 * 4];
    
    cppKiwi.gameboy.setInputGetter(&GetInput);
    cppKiwi.gameboy.setSaveDir(cppKiwi.save_states_path.string());
}


void kiwi::destroy_system(void) {
    kiwi::initialize_system();
}


void kiwi::insert_disc(std::string path) {
    cppKiwi.gameboy.load(path);
}


bool kiwi::is_paused(bool change, bool set_paused) {
    if (change)
        cppKiwi.paused.store(set_paused);
    return cppKiwi.paused.load();
}

bool kiwi::is_running(bool change, bool set_running) {
    if (change)
        cppKiwi.running.store(set_running);
    return cppKiwi.running.load();
}


void kiwi::start(void) {
    cppKiwi.thread = std::jthread([&](std::stop_token token) {
        using namespace std::chrono;
        
        const auto frameDuration = duration<double>(1.0 / 60.0);
        
        while (!token.stop_requested()) {
            {
                std::unique_lock lock(cppKiwi.mutex);
                cppKiwi.cv.wait(lock, token, []() {
                    return !cppKiwi.paused.load();
                });
                
                if (token.stop_requested())
                    break;
            }
            
            auto frameStart = steady_clock::now();
            
            size_t samples = 2064;
            while (cppKiwi.gameboy.runFor(cppKiwi.fb, 160, cppKiwi.ab, samples) == -1)
                kiwi::audio_callback(kiwi::context, cppKiwi.ab, samples);
            
            kiwi::video_callback(kiwi::context, cppKiwi.fb, 0x00);

            // Limit FPS
            auto frameEnd = steady_clock::now();
            auto elapsed = frameEnd - frameStart;
            if (elapsed < frameDuration)
                std::this_thread::sleep_for(frameDuration - elapsed);
        }
    });
}

void kiwi::stop(void) {
    cppKiwi.thread.request_stop();
    if (cppKiwi.thread.joinable())
        cppKiwi.thread.join();
    
    cppKiwi.paused.store(false);
    cppKiwi.running.store(false);
}


int kiwi::framebuffer_height(void) {
    return 144;
}

int kiwi::framebuffer_width(void) {
    return 160;
}


void kiwi::audio_buffer_callback(kiwi::AudioVideoBufferCallback callback) {
    kiwi::audio_callback = callback;
}

void kiwi::video_buffer_callback(kiwi::AudioVideoBufferCallback callback) {
    kiwi::video_callback = callback;
}


void kiwi::press_button(uint32_t button) {
    cppKiwi.activeInput[0] |= button;
}

void kiwi::release_button(uint32_t button) {
    cppKiwi.activeInput[0] &= ~button;
}


void kiwi::set_context(void* context) {
    kiwi::context = context;
}
