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
#include "avocado/memory_card/card_formats.h"
#include "avocado/sound/sound.h"

#import "Mandarine-Swift.h"
using namespace Mandarine;

#include <_printf.h>
#include <filesystem>
#include <fstream>
#include <sstream>

#include <fmt/core.h>

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

namespace Sound {
std::deque<uint16_t> buffer;
std::mutex audioMutex;
};  // namespace Sound

namespace {
// SDL_AudioDeviceID deviceID = 0;
// SDL_AudioStream* stream = nullptr;

/*
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
 */
}  // namespace

void Sound::init() {
    /*
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
     */
}

void Sound::play() { /*SDL_ResumeAudioStreamDevice(stream);*/ }

void Sound::stop() { /*SDL_PauseAudioStreamDevice(stream);*/ }

void Sound::close() { /*SDL_DestroyAudioStream(stream);*/ }

void Sound::clearBuffer() { buffer.clear(); }

struct CPPMandarine {
    MandarineCommon mandarineCommon{MandarineCommon::init()};
    MandarineSystem mandarineSystem{MandarineSystem::init()};
    
    std::unique_ptr<System> system;
    
    std::filesystem::path mandarine_path, memory_cards_path, system_data_path;
} cppMandarine;


void mandarine::print_about(void) {
    printf("Welcome to Mandarine\n");
    printf("PlayStation 1 emulator based on Avocado\n");
}


void mandarine::initialize_paths(void) {
    auto mandarineDirectoryURL{cppMandarine.mandarineCommon.getMandarineDirectoryURL()};
    if (mandarineDirectoryURL.isSome()) {
        auto mandarine_path{std::filesystem::path{mandarineDirectoryURL.get()}};
        
        cppMandarine.mandarine_path = mandarine_path;
        cppMandarine.memory_cards_path = mandarine_path / "memory_cards";
        cppMandarine.system_data_path = mandarine_path / "system_data";
    }
    
    auto memory_card = [](std::string index) -> std::filesystem::path {
        auto system_data_path = cppMandarine.memory_cards_path / "";
        return system_data_path.string() + "memory_card_" + index + ".mcr";
    };
    
    auto bios = cppMandarine.system_data_path / "bios.bin";
    
    auto memory_card_0 = memory_card("0");
    auto memory_card_1 = memory_card("1");
    
    config.bios = bios.string();
    config.memoryCard[0].path = memory_card_0.string();
    config.memoryCard[1].path = memory_card_1.string();
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
    cppMandarine.system = system_tools::hardReset();
}


void mandarine::destroy_system(void) {
    mandarine::initialize_system();
}


void mandarine::insert_disc(std::string url) {
    system_tools::loadFile(cppMandarine.system, url);
}
