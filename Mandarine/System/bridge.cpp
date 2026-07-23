//
//  bridge.cpp
//  Mandarine
//
//  Created by Jarrod Norwell on 14/6/2026.
//

#include "avocado/bridge.h"
#include "avocado/config.h"
#include "avocado/system.h"
#include "avocado/system_tools.h"
#include "avocado/input/input_manager.h"
#include "avocado/memory_card/card_formats.h"
#include "avocado/sound/sound.h"

#import "Mandarine-Swift.h"
using namespace Mandarine;

#include <_printf.h>
#include <atomic>
#include <condition_variable>
#include <filesystem>
#include <fstream>
#include <mutex>
#include <sstream>
#include <thread>

#include <fmt/core.h>
#include <fmt/format.h>
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

bool fileExists(const std::string &path) {
    return std::filesystem::exists(path);
}

std::vector<uint8_t> getFileContents(const std::string &path) {
    std::vector<uint8_t> contents;

    FILE *f = fopen(path.c_str(), "rb");
    if (!f) return contents;

    fseek(f, 0, SEEK_END);
    int filesize = ftell(f);
    fseek(f, 0, SEEK_SET);

    contents.resize(filesize);
    fread(&contents[0], 1, filesize, f);

    fclose(f);
    return contents;
}

bool putFileContents(const std::string &name, const std::vector<unsigned char> &contents) {
    FILE *f = fopen(name.c_str(), "wb");
    if (!f) return false;

    fwrite(&contents[0], 1, contents.size(), f);

    fclose(f);

    return true;
}

bool putFileContents(const std::string &path, const std::string contents) {
    FILE *f = fopen(path.c_str(), "wb");
    if (!f) return false;

    fwrite(&contents[0], 1, contents.size(), f);

    fclose(f);

    return true;
}

std::string getFileContentsAsString(const std::string &path) {
    std::ifstream file(path);
    if (!file.is_open())
        throw std::runtime_error("Could not open file");
    
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

size_t getFileSize(const std::string &path) {
    return std::filesystem::file_size(path);
}

class GCInputManager : public InputManager {
public:
    GCInputManager() {}
    
    void press(std::string button, int index) {
        state[fmt::format("controller/{}/{}", index, button).c_str()] = AnalogValue(true);
    }
    
    void release(std::string button, int index) {
        state[fmt::format("controller/{}/{}", index, button).c_str()] = AnalogValue(false);
    }
    
    void drag(std::string button, int index, uint8_t value) {
        state[fmt::format("controller/{}/{}", index, button).c_str()] = AnalogValue(value);
    }
};

namespace Sound {
std::deque<uint16_t> buffer;
std::mutex audioMutex;
};  // namespace Sound

namespace {
SDL_AudioDeviceID deviceID = 0;
SDL_AudioStream* stream = nullptr;

void audioCallback(void* userdata, SDL_AudioStream* stream, int additional_amount, int total_amount) {
    (void)userdata;
    
    // additional_amount is byte count
    if (additional_amount <= 0)
        return;
    
    std::vector<uint8_t> data(additional_amount);
    
    std::unique_lock<std::mutex> lock(Sound::audioMutex);
    
    size_t samples_available = Sound::buffer.size();
    size_t samples_needed = additional_amount / sizeof(int16_t);
    
    size_t samples_to_copy = std::min(samples_available, samples_needed);
    
    for (size_t i = 0; i < samples_to_copy; i++) {
        int16_t sample = Sound::buffer.front();
        Sound::buffer.pop_front();
        
        data.at(i * 2) = (uint8_t)sample & 0xFF;
        data.at(i * 2 + 1) = (uint8_t)(sample >> 8) & 0xFF;
    }
    
    SDL_PutAudioStreamData(stream, data.data(), additional_amount);
}
}  // namespace

void Sound::init() {
    SDL_SetMainReady();
    SDL_Init(SDL_INIT_AUDIO);
    
    SDL_AudioSpec spec;
    SDL_zero(spec);
    spec.channels = 2;
    spec.freq = 44100;
    spec.format = SDL_AUDIO_S16;
    
    deviceID = SDL_OpenAudioDevice(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &spec);
    stream = SDL_OpenAudioDeviceStream(deviceID, &spec, &audioCallback, nullptr);
    
    SDL_ResumeAudioStreamDevice(stream);
}

void Sound::play() {
    SDL_ResumeAudioStreamDevice(stream);
}

void Sound::stop() {
    SDL_PauseAudioStreamDevice(stream);
}

void Sound::close() {
    SDL_DestroyAudioStream(stream);
}

void Sound::clearBuffer() {
    buffer.clear();
}

double limitFramerate(bool framelimiter, bool ntsc) {
    static double timeToSkip = 0;
    static double counterFrequency = (double)SDL_GetPerformanceFrequency();
    static double startTime = SDL_GetPerformanceCounter() / counterFrequency;
    static double fpsTime = 0.0;
    static double fps = 0;
    static int deltaFrames = 0;

    double currentTime = SDL_GetPerformanceCounter() / counterFrequency;
    double deltaTime = currentTime - startTime;

    double frameTime = ntsc ? (1.0 / timing::NTSC_FRAMERATE) : (1.0 / timing::PAL_FRAMERATE);

    if (framelimiter && deltaTime < frameTime) {
        // If deltaTime was shorter than frameTime - spin
        if (deltaTime < frameTime - timeToSkip) {
            while (deltaTime < frameTime - timeToSkip) {  // calculate real difference
                SDL_Delay(1);

                currentTime = SDL_GetPerformanceCounter() / counterFrequency;
                deltaTime = currentTime - startTime;
            }
            timeToSkip -= (frameTime - deltaTime);
            if (timeToSkip < 0.0) timeToSkip = 0.0;
        } else {  // Else - accumulate
            timeToSkip += deltaTime - frameTime;
        }
    }

    startTime = currentTime;
    fpsTime += deltaTime;
    deltaFrames++;

    if (fpsTime > 0.25f) {
        fps = (double)deltaFrames / fpsTime;
        deltaFrames = 0;
        fpsTime = 0.0;
    }

    return fps;
}


struct MandarineCPP {
    MandarineCommon mandarineCommon{MandarineCommon::init()};
    MandarineSystem mandarineSystem{MandarineSystem::init()};
    
    std::unique_ptr<GCInputManager> controller;
    std::unique_ptr<System> system;
    
    std::filesystem::path mandarine_path, memory_cards_path, system_data_path;
    
    std::jthread thread;
    std::mutex mutex;
    std::condition_variable_any cv;
} m_cntnr;

void mandarine::print_about(void) {
    printf("Welcome to Mandarine\n");
    printf("PlayStation 1 emulator based on Avocado\n");
}


std::string mandarine::disc_identifier(std::string path) {
    const int blockSize = 1024 * 1024; // Read in 1MB blocks
    std::ifstream binFile(path, std::ios::binary);
    if (!binFile.is_open()) {
        throw std::runtime_error("Failed to open the .bin file");
    }

    binFile.seekg(0, std::ios::end);
    size_t fileSize = binFile.tellg();
    binFile.seekg(0, std::ios::beg);

    std::vector<char> buffer(blockSize);
    size_t bytesRead = 0;

    while (bytesRead < fileSize) {
        size_t readSize = std::min(blockSize, (int)(fileSize - bytesRead));
        binFile.read(buffer.data(), readSize);

        std::string content(buffer.begin(), buffer.begin() + readSize);
        size_t bootPos = content.find("BOOT");

        if (bootPos != std::string::npos) {
            size_t start = content.find(':', bootPos);
            if (start == std::string::npos) {
                throw std::runtime_error("Invalid BOOT line format");
            }

            ++start; // move past ':'

            // Skip optional slash/backslash and whitespace
            while (start < content.size() &&
                   (content[start] == '\\' ||
                    content[start] == '/' ||
                    std::isspace(static_cast<unsigned char>(content[start]))))
            {
                ++start;
            }

            size_t end = content.find(';', start);
            if (end == std::string::npos) {
                throw std::runtime_error("Invalid BOOT line format");
            }

            return content.substr(start, end - start);
        }

        bytesRead += readSize;
    }

    throw std::runtime_error("BOOT line not found in the file");
}


void mandarine::initialize_paths(void) {
    auto mandarineDirectoryURL{m_cntnr.mandarineCommon.getMandarineDirectoryURL()};
    if (mandarineDirectoryURL.isSome()) {
        auto mandarine_path{std::filesystem::path{mandarineDirectoryURL.get()}};
        
        m_cntnr.mandarine_path = mandarine_path;
        m_cntnr.memory_cards_path = mandarine_path / "memory_cards";
        m_cntnr.system_data_path = mandarine_path / "system_data";
    }
    
    auto memory_card = [](std::string index) -> std::filesystem::path {
        auto system_data_path = m_cntnr.memory_cards_path / "";
        return system_data_path.string() + "memory_card_" + index + ".mcr";
    };
    
    auto bios = m_cntnr.system_data_path / "bios.bin";
    
    auto memory_card_0 = memory_card("0");
    auto memory_card_1 = memory_card("1");
    
    config.bios = bios.string();
    config.memoryCard[0].path = memory_card_0.string();
    config.memoryCard[1].path = memory_card_1.string();
    
    config.debug.log.bios = 1;
}

void mandarine::initialize_memory_cards(void) {
    auto memory_card_0{std::filesystem::path{config.memoryCard[0].path}};
    auto memory_card_1{std::filesystem::path{config.memoryCard[1].path}};
    
    if (!std::filesystem::exists(memory_card_0)) {
        std::array<uint8_t, memory_card::MEMCARD_SIZE> data;
        memory_card::format(data);
        memory_card::save(data, memory_card_0.string());
    }
    
    if (!std::filesystem::exists(memory_card_1)) {
        std::array<uint8_t, memory_card::MEMCARD_SIZE> data;
        memory_card::format(data);
        memory_card::save(data, memory_card_1.string());
    }
}

void mandarine::initialize_system(void) {
    m_cntnr.controller.reset();
    Sound::close();
    
    m_cntnr.system = system_tools::hardReset();
    m_cntnr.system->state = System::State::stop;
    
    Sound::init();
    m_cntnr.controller = std::make_unique<GCInputManager>();
    InputManager::setInstance(m_cntnr.controller.get());
}


void mandarine::destroy_system(void) {
    mandarine::initialize_system();
}


void mandarine::insert_disc(std::string path) {
    system_tools::loadFile(m_cntnr.system, path);
}


bool mandarine::is_paused(bool change, bool set_paused) {
    if (change)
        m_cntnr.system->state = set_paused ? System::State::pause : System::State::run;
    return m_cntnr.system->state == System::State::pause;
}

bool mandarine::is_running(bool change, bool set_running) {
    if (change)
        m_cntnr.system->state = set_running ? System::State::run : System::State::stop;
    return m_cntnr.system->state == System::State::run;
}


void mandarine::start(void) {
    m_cntnr.system->state = System::State::run;
    m_cntnr.thread = std::jthread([&](std::stop_token token) {
        using namespace std::chrono;
        
        while (!token.stop_requested()) {
            switch (m_cntnr.system->state) {
                case System::State::halted:
                    printf("halted\n");
                    break;
                case System::State::stop:
                    printf("stopped\n");
                    break;
                case System::State::pause:
                    printf("paused\n");
                    continue;
                case System::State::run:
                    m_cntnr.system->gpu->clear();
                    m_cntnr.system->controller->update();
                    
                    m_cntnr.system->emulateFrame();
                    
                    if (m_cntnr.system->gpu->gp1_08.colorDepth == gpu::GP1_08::ColorDepth::bit24)
                        mandarine::callback_24bit(mandarine::context, m_cntnr.system->gpu->vram.data());
                    else
                        mandarine::callback_15bit(mandarine::context, m_cntnr.system->gpu->vram.data());
                    
                    limitFramerate(true, m_cntnr.system->gpu->isNtsc());
                    break;
            }
        }
    });
}

void mandarine::stop(void) {
    m_cntnr.thread.request_stop();
    if (m_cntnr.thread.joinable())
        m_cntnr.thread.join();
    
    system_tools::saveMemoryCard(m_cntnr.system, 0, true);
    system_tools::saveMemoryCard(m_cntnr.system, 1, true);
    
    m_cntnr.system->state = System::State::stop;
    
    mandarine::destroy_system();
}


int16_t mandarine::framebuffer_start_x(void) {
    return m_cntnr.system->gpu->displayAreaStartX;
}

int16_t mandarine::framebuffer_start_y(void) {
    return m_cntnr.system->gpu->displayAreaStartY;
}

int mandarine::framebuffer_height(void) {
    return m_cntnr.system->gpu->gp1_08.getVerticalResoulution();
}

int mandarine::framebuffer_width(void) {
    return m_cntnr.system->gpu->gp1_08.getHorizontalResoulution();
}


void mandarine::video_buffer_callback_15bit(mandarine::VideoBufferCallback15Bit callback) {
    mandarine::callback_15bit = callback;
}

void mandarine::video_buffer_callback_24bit(mandarine::VideoBufferCallback24Bit callback) {
    mandarine::callback_24bit = callback;
}


void mandarine::press_button(std::string button, int index) {
    m_cntnr.controller->press(button, index);
}

void mandarine::release_button(std::string button, int index) {
    m_cntnr.controller->release(button, index);
}

void mandarine::drag_thumbstick(std::string thumbstick, uint8_t value) {
    m_cntnr.controller->drag(thumbstick, 1, value);
}


void mandarine::set_context(void* context) {
    mandarine::context = context;
}


int busToken = 0;
void mandarine::set_setting(mandarine::SETTING setting, bool value) {
    switch (setting) {
        case mandarine::SETTING::WIDESCREEN:
            config.options.graphics.widescreen = value;
            break;
        case mandarine::SETTING::FORCE_WIDESCREEN:
            config.options.graphics.forceWidescreen = value;
            break;
        case mandarine::SETTING::SOUND_ENABLED:
            config.options.sound.enabled = value;
            if (config.options.sound.enabled)
                Sound::play();
            else
                Sound::stop();
            break;
        case mandarine::SETTING::EXTENDED_MEMORY:
            config.options.system.ram8mb = value;
            break;
    }
}
