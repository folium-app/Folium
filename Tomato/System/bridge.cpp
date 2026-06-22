//
//  bridge.cpp
//  Tomato
//
//  Created by Jarrod Norwell on 21/6/2026.
//

#include "nba/bridge.hpp"
#include "nba/config.hpp"
#include "nba/core_base.hpp"
#include "nba/rom/header.hpp"
#include "nba/rom/backup/flash.hpp"
#include "nba/rom/backup/sram.hpp"

#include <_printf.h>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <filesystem>
#include <fstream>
#include <functional>
#include <map>
#include <mutex>
#include <queue>
#include <sstream>
#include <thread>
#include <vector>

#include "Tomato-Swift.h"
using namespace Tomato;

using System = nba::CoreBase;

namespace nba {
enum class GPIODeviceType {
    None = 0,
    RTC = 1,
    SolarSensor = 2
};

struct GameInfo {
    Config::BackupType backup_type = Config::BackupType::Detect;
    GPIODeviceType gpio = GPIODeviceType::None;
    bool mirror = false;
};

extern const std::map<std::string, GameInfo> g_game_db;

constexpr GPIODeviceType operator|(GPIODeviceType lhs, GPIODeviceType rhs) {
    return (GPIODeviceType)((int)lhs | (int)rhs);
}

constexpr int operator&(GPIODeviceType lhs, GPIODeviceType rhs) {
    return (int)lhs & (int)rhs;
}


struct BIOSLoader {
    enum class Result {
        CannotFindFile,
        CannotOpenFile,
        BadImage,
        Success
    };
    
    static auto Load(std::unique_ptr<System>& core, std::filesystem::path const& path) -> Result;
};

static constexpr size_t kBIOSSize = 0x4000;

struct FrameLimiter {
    FrameLimiter(float fps = 60.0) {
        Reset(fps);
    }
    
    void Reset();
    void Reset(float fps);
    auto GetFastForward() const -> bool;
    void SetFastForward(bool value);
    
    void Run(std::function<void(void)> frame_advance, std::function<void(float)> update_fps);
    
private:
    static constexpr int kMillisecondsPerSecond = 1000;
    static constexpr int kMicrosecondsPerSecond = 1000000;
    
    int frame_count = 0;
    int frame_duration;
    float frames_per_second;
    bool fast_forward = false;
    
    std::chrono::time_point<std::chrono::steady_clock> timestamp_target;
    std::chrono::time_point<std::chrono::steady_clock> timestamp_fps_update;
};

struct EmulatorThread {
    EmulatorThread();
    ~EmulatorThread();
    
    bool IsRunning() const;
    bool IsPaused() const;
    void SetPause(bool value);
    bool GetFastForward() const;
    void SetFastForward(bool enabled);
    void SetFrameRateCallback(std::function<void(float)> callback);
    void SetPerFrameCallback(std::function<void()> callback);
    
    void Start(std::unique_ptr<System> core);
    std::unique_ptr<System> Stop();
    
    void Reset();
    void SetKeyStatus(Key key, bool pressed);
    
private:
    enum class MessageType : u8 {
        Reset,
        SetKeyStatus
    };
    
    struct Message {
        MessageType type;
        union {
            struct {
                Key key;
                u8bool pressed;
            } set_key_status;
        };
    };
    
    void PushMessage(const Message& message);
    void ProcessMessages();
    void ProcessMessage(const Message& message);
    
    static constexpr int k_number_of_input_subframes = 4;
    static constexpr int k_cycles_per_second = 16777216;
    static constexpr int k_cycles_per_frame = 280896;
    static constexpr int k_cycles_per_subframe = k_cycles_per_frame / k_number_of_input_subframes;
    
    static_assert(k_cycles_per_frame % k_number_of_input_subframes == 0);
    
    std::queue<Message> msg_queue;
    std::mutex msg_queue_mutex;
    
    std::unique_ptr<CoreBase> core;
    FrameLimiter frame_limiter;
    std::thread thread;
    std::atomic_bool running = false;
    bool paused = false;
    std::function<void(float)> frame_rate_cb = [](float) {};
    std::function<void()> per_frame_cb = []() {};
};

struct ROMLoader {
    enum class Result {
        CannotFindFile,
        CannotOpenFile,
        BadImage,
        Success
    };
    
    static auto Load(std::unique_ptr<System>& core, std::filesystem::path const& path,
                     Config::BackupType backup_type = Config::BackupType::Detect, GPIODeviceType force_gpio = GPIODeviceType::None) -> Result;
    
    static auto Load(std::unique_ptr<System>& core, std::filesystem::path const& rom_path, std::filesystem::path const& save_path,
                     Config::BackupType backup_type = Config::BackupType::Detect, GPIODeviceType force_gpio = GPIODeviceType::None) -> Result;
    
private:
    static auto ReadFile(std::filesystem::path const& path, std::vector<u8>& file_data) -> Result;
    
    static auto GetGameInfo(
                            std::vector<u8>& file_data
                            ) -> GameInfo;
    
    static auto GetBackupType(
                              std::vector<u8>& file_data
                              ) -> Config::BackupType;
    
    static auto CreateBackup(
                             std::unique_ptr<CoreBase>& core,
                             std::filesystem::path const& save_path,
                             Config::BackupType backup_type
                             ) -> std::unique_ptr<Backup>;
    
    static auto RoundSizeToPowerOfTwo(size_t size) -> size_t;
};

struct SWVideoDevice : VideoDevice {
    ~SWVideoDevice() override;
    void Draw(u32* buffer) override;
};
}

auto nba::BIOSLoader::Load(std::unique_ptr<System>& system, std::filesystem::path const& path) -> Result {
    if (!std::filesystem::exists(path))
        return Result::CannotFindFile;
    
    if (std::filesystem::is_directory(path))
        return Result::CannotOpenFile;
    
    auto size = std::filesystem::file_size(path);
    if (size != kBIOSSize)
        return Result::BadImage;
    
    auto file_stream = std::ifstream{path.c_str(), std::ios::binary};
    if (!file_stream.good())
        return Result::CannotOpenFile;
    
    std::vector<u8> file_data(size);
    file_stream.read((char*)file_data.data(), size);
    file_stream.close();
    
    system->Attach(file_data);
    return Result::Success;
}

void nba::FrameLimiter::Reset() {
    Reset(frames_per_second);
}

void nba::FrameLimiter::Reset(float fps) {
    frame_count = 0;
    frame_duration = static_cast<int>(kMicrosecondsPerSecond / fps);
    frames_per_second = fps;
    fast_forward = false;
    timestamp_target = timestamp_fps_update = std::chrono::steady_clock::now();
}

auto nba::FrameLimiter::GetFastForward() const -> bool {
    return fast_forward;
}

void nba::FrameLimiter::SetFastForward(bool value) {
    if (fast_forward != value) {
        fast_forward = value;
        if (!fast_forward)
            timestamp_target = std::chrono::steady_clock::now();
    }
}

void nba::FrameLimiter::Run(std::function<void(void)> frame_advance,std::function<void(float)> update_fps) {
    if(!fast_forward)
        timestamp_target += std::chrono::microseconds(frame_duration);
    
    frame_advance();
    frame_count++;
    
    auto now = std::chrono::steady_clock::now();
    auto fps_update_delta = std::chrono::duration_cast<std::chrono::milliseconds>(now - timestamp_fps_update).count();
    
    if (fps_update_delta >= kMillisecondsPerSecond) {
        update_fps(frame_count * static_cast<float>(kMillisecondsPerSecond) / fps_update_delta);
        frame_count = 0;
        timestamp_fps_update = std::chrono::steady_clock::now();
    }
    
    if (!fast_forward)
        std::this_thread::sleep_until(timestamp_target);
}


nba::EmulatorThread::EmulatorThread() {
    frame_limiter.Reset(k_cycles_per_second / static_cast<float>(k_cycles_per_subframe));
}

nba::EmulatorThread::~EmulatorThread() {
    Stop();
}

bool nba::EmulatorThread::IsRunning() const {
    return running;
}

bool nba::EmulatorThread::IsPaused() const {
    return paused;
}

void nba::EmulatorThread::SetPause(bool value) {
    paused = value;
}

bool nba::EmulatorThread::GetFastForward() const {
    return frame_limiter.GetFastForward();
}

void nba::EmulatorThread::SetFastForward(bool enabled) {
    frame_limiter.SetFastForward(enabled);
}

void nba::EmulatorThread::SetFrameRateCallback(std::function<void(float)> callback) {
    frame_rate_cb = callback;
}

void nba::EmulatorThread::SetPerFrameCallback(std::function<void()> callback) {
    per_frame_cb = callback;
}

void nba::EmulatorThread::Start(std::unique_ptr<CoreBase> core) {
    Assert(!running, "Started an emulator thread which was already running");
    
    this->core = std::move(core);
    running = true;
    
    thread = std::thread{[this]() {
        frame_limiter.Reset();
        
        while (running.load()) {
            ProcessMessages();
            
            frame_limiter.Run([this]() {
                if (!paused) {
                    per_frame_cb();
                    this->core->Run(k_cycles_per_subframe);
                }
            }, [this](float fps) {
                float real_fps = fps / k_number_of_input_subframes;
                if (paused)
                    real_fps = 0;
                frame_rate_cb(real_fps);
            });
        }
        
        ProcessMessages();
    }};
}

std::unique_ptr<System> nba::EmulatorThread::Stop() {
    if (IsRunning()) {
        running = false;
        thread.join();
    }
    
    return std::move(core);
}

void nba::EmulatorThread::Reset() {
    PushMessage({
        .type = MessageType::Reset
    });
}

void nba::EmulatorThread::SetKeyStatus(Key key, bool pressed) {
    PushMessage({
        .type = MessageType::SetKeyStatus,
        .set_key_status = {
            .key = key,
            .pressed = static_cast<u8bool>(pressed)
        }
    });
}

void nba::EmulatorThread::PushMessage(const Message& message) {
    if(!IsRunning())
        return;
    
    if (std::this_thread::get_id() == thread.get_id())
        ProcessMessage(message);
    else {
        std::lock_guard lock_guard{msg_queue_mutex};
        msg_queue.push(message);
    }
}

void nba::EmulatorThread::ProcessMessages() {
    std::lock_guard lock_guard{msg_queue_mutex};
    
    while (!msg_queue.empty()) {
        ProcessMessage(msg_queue.front());
        msg_queue.pop();
    }
}

void nba::EmulatorThread::ProcessMessage(const Message& message) {
    switch (message.type) {
        case MessageType::Reset: {
            core->Reset();
            break;
        }
        case MessageType::SetKeyStatus: {
            core->SetKeyStatus(message.set_key_status.key, message.set_key_status.pressed);
            break;
        }
        default:
            Assert(false, "unhandled message type: {}", static_cast<int>(message.type));
            break;
    }
}


namespace nba {
const std::map<std::string, GameInfo> g_game_db {
    { "ALFP", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - The Legacy of Goku II (Europe)(En,Fr,De,Es,It) */
    { "ALGP", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - The Legacy of Goku (Europe)(En,Fr,De,Es,It) */
    { "AROP", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Rocky (Europe)(En,Fr,De,Es,It) */
    { "AR8e", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Rocky (USA)(En,Fr,De,Es,It) */
    { "AXVE", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Ruby Version (USA, Europe) */
    { "AXPE", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Sapphire Version (USA, Europe) */
    { "AX4P", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Super Mario Advance 4 - Super Mario Bros. 3 (Europe)(En,Fr,De,Es,It) */
    { "A2YE", { Config::BackupType::None, GPIODeviceType::None, false } },      /* Top Gun - Combat Zones (USA)(En,Fr,De,Es,It) */
    { "BDBP", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - Taiketsu (Europe)(En,Fr,De,Es,It) */
    { "BM5P", { Config::BackupType::FLASH_64, GPIODeviceType::None, false } },  /* Mario vs. Donkey Kong (Europe) */
    { "BPEE", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Emerald Version (USA, Europe) */
    { "BY6P", { Config::BackupType::SRAM, GPIODeviceType::None, false } },      /* Yu-Gi-Oh! - Ultimate Masters - World Championship Tournament 2006 (Europe)(En,Jp,Fr,De,Es,It) */
    { "B24E", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon Mystery Dungeon - Red Rescue Team (USA, Australia) */
    { "FADE", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Castlevania (USA, Europe) */
    { "FBME", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Bomberman (USA, Europe) */
    { "FDKE", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Donkey Kong (USA, Europe) */
    { "FDME", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Dr. Mario (USA, Europe) */
    { "FEBE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },   /* Classic NES Series - Excitebike (USA, Europe) */
    { "FICE", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Ice Climber (USA, Europe) */
    { "FLBE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },   /* Classic NES Series - Zelda II - The Adventure of Link (USA, Europe) */
    { "FMRE", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Metroid (USA, Europe) */
    { "FP7E", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Pac-Man (USA, Europe) */
    { "FSME", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Super Mario Bros. (USA, Europe) */
    { "FXVE", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },   /* Classic NES Series - Xevious (USA, Europe) */
    { "FZLE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },   /* Classic NES Series - Legend of Zelda (USA, Europe) */
    { "KYGP", { Config::BackupType::EEPROM_64/*_SENSOR*/, GPIODeviceType::None, false } }, /* Yoshi's Universal Gravitation (Europe)(En,Fr,De,Es,It) */
    { "U3IP", { Config::BackupType::Detect, GPIODeviceType::RTC | GPIODeviceType::SolarSensor, false } }, /* Boktai - The Sun Is in Your Hand (Europe)(En,Fr,De,Es,It) */
    { "U32P", { Config::BackupType::Detect, GPIODeviceType::RTC | GPIODeviceType::SolarSensor, false } }, /* Boktai 2 - Solar Boy Django (Europe)(En,Fr,De,Es,It) */
    { "AGFE", { Config::BackupType::FLASH_64, GPIODeviceType::RTC, false } },   /* Golden Sun - The Lost Age (USA) */
    { "AGSE", { Config::BackupType::FLASH_64, GPIODeviceType::RTC, false } },   /* Golden Sun (USA) */
    { "ALFE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - The Legacy of Goku II (USA) */
    { "ALGE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - The Legacy of Goku (USA) */
    { "AX4E", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Super Mario Advance 4 - Super Mario Bros 3 - Super Mario Advance 4 v1.1 (USA) */
    { "BDBE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - Taiketsu (USA) */
    { "BG3E", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - Buu's Fury (USA) */
    { "BLFE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* 2 Games in 1 - Dragon Ball Z - The Legacy of Goku I & II (USA) */
    { "BPRE", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Fire Red Version (USA, Europe) */
    { "BPGE", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Leaf Green Version (USA, Europe) */
    { "BT4E", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball GT - Transformation (USA) */
    { "BUFE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* 2 Games in 1 - Dragon Ball Z - Buu's Fury + Dragon Ball GT - Transformation (USA) */
    { "BYGE", { Config::BackupType::SRAM, GPIODeviceType::None, false } },      /* Yu-Gi-Oh! GX - Duel Academy (USA) */
    { "KYGE", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Yoshi - Topsy-Turvy (USA) */
    { "PSAE", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* e-Reader (USA) */
    { "U3IE", { Config::BackupType::Detect, GPIODeviceType::RTC | GPIODeviceType::SolarSensor, false } }, /* Boktai - The Sun Is in Your Hand (USA) */
    { "U32E", { Config::BackupType::Detect, GPIODeviceType::RTC | GPIODeviceType::SolarSensor, false } }, /* Boktai 2 - Solar Boy Django (USA) */
    { "ALFJ", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Dragon Ball Z - The Legacy of Goku II International (Japan) */
    { "AXPJ", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pocket Monsters - Sapphire (Japan) */
    { "AXVJ", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pocket Monsters - Ruby (Japan) */
    { "AX4J", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Super Mario Advance 4 (Japan) */
    { "BFTJ", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* F-Zero - Climax (Japan) */
    { "BGWJ", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Game Boy Wars Advance 1+2 (Japan) */
    { "BKAJ", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Sennen Kazoku (Japan) */
    { "BPEJ", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pocket Monsters - Emerald (Japan) */
    { "BPGJ", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pocket Monsters - Leaf Green (Japan) */
    { "BPRJ", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pocket Monsters - Fire Red (Japan) */
    { "BDKJ", { Config::BackupType::EEPROM_64, GPIODeviceType::None, false } }, /* Digi Communication 2 - Datou! Black Gemagema Dan (Japan) */
    { "BR4J", { Config::BackupType::Detect, GPIODeviceType::RTC, false } },     /* Rockman EXE 4.5 - Real Operation (Japan) */
    { "FSRJ", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },  /* Famicom Mini - Dai-2-ji Super Robot Taisen (Japan) (Promo) */
    { "FGZJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini - Kidou Senshi Z Gundam - Hot Scramble (Japan) (Promo) */
    { "FMBJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 01 - Super Mario Bros. (Japan) */
    { "FCLJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 12 - Clu Clu Land (Japan) */
    { "FBFJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 13 - Balloon Fight (Japan) */
    { "FWCJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 14 - Wrecking Crew (Japan) */
    { "FDMJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 15 - Dr. Mario (Japan) */
    { "FDDJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 16 - Dig Dug (Japan) */
    { "FTBJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 17 - Takahashi Meijin no Boukenjima (Japan) */
    { "FMKJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 18 - Makaimura (Japan) */
    { "FTWJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 19 - Twin Bee (Japan) */
    { "FGGJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 20 - Ganbare Goemon! Karakuri Douchuu (Japan) */
    { "FM2J", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 21 - Super Mario Bros. 2 (Japan) */
    { "FNMJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 22 - Nazo no Murasame Jou (Japan) */
    { "FMRJ", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },  /* Famicom Mini Vol. 23 - Metroid (Japan) */
    { "FPTJ", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },  /* Famicom Mini Vol. 24 - Hikari Shinwa - Palthena no Kagami (Japan) */
    { "FLBJ", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },  /* Famicom Mini Vol. 25 - The Legend of Zelda 2 - Link no Bouken (Japan) */
    { "FFMJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 26 - Famicom Mukashi Banashi - Shin Onigashima - Zen Kou Hen (Japan) */
    { "FTKJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 27 - Famicom Tantei Club - Kieta Koukeisha - Zen Kou Hen (Japan) */
    { "FTUJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 28 - Famicom Tantei Club Part II - Ushiro ni Tatsu Shoujo - Zen Kou Hen (Japan) */
    { "FADJ", { Config::BackupType::EEPROM_4,  GPIODeviceType::None, true } },  /* Famicom Mini Vol. 29 - Akumajou Dracula (Japan) */
    { "FSDJ", { Config::BackupType::EEPROM_64, GPIODeviceType::None, true } },  /* Famicom Mini Vol. 30 - SD Gundam World - Gachapon Senshi Scramble Wars (Japan) */
    { "KHPJ", { Config::BackupType::EEPROM_64/*_SENSOR*/, GPIODeviceType::None, false } }, /* Koro Koro Puzzle - Happy Panechu! (Japan) */
    { "KYGJ", { Config::BackupType::EEPROM_64/*_SENSOR*/, GPIODeviceType::None, false } }, /* Yoshi no Banyuuinryoku (Japan) */
    { "PSAJ", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Card e-Reader+ (Japan) */
    { "U3IJ", { Config::BackupType::Detect, GPIODeviceType::RTC | GPIODeviceType::SolarSensor, false } },     /* Bokura no Taiyou - Taiyou Action RPG (Japan) */
    { "U32J", { Config::BackupType::Detect, GPIODeviceType::RTC | GPIODeviceType::SolarSensor, false } },     /* Zoku Bokura no Taiyou - Taiyou Shounen Django (Japan) */
    { "U33J", { Config::BackupType::Detect, GPIODeviceType::RTC | GPIODeviceType::SolarSensor, false } },     /* Shin Bokura no Taiyou - Gyakushuu no Sabata (Japan) */
    { "AXPF", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Version Saphir (France) */
    { "AXVF", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Version Rubis (France) */
    { "BPEF", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Version Emeraude (France) */
    { "BPGF", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Version Vert Feuille (France) */
    { "BPRF", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Version Rouge Feu (France) */
    { "AXPI", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Versione Zaffiro (Italy) */
    { "AXVI", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Versione Rubino (Italy) */
    { "BPEI", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Versione Smeraldo (Italy) */
    { "BPGI", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Versione Verde Foglia (Italy) */
    { "BPRI", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Versione Rosso Fuoco (Italy) */
    { "AXPD", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Saphir-Edition (Germany) */
    { "AXVD", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Rubin-Edition (Germany) */
    { "BPED", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Smaragd-Edition (Germany) */
    { "BPGD", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Blattgruene Edition (Germany) */
    { "BPRD", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Feuerrote Edition (Germany) */
    { "AXPS", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Edicion Zafiro (Spain) */
    { "AXVS", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Edicion Rubi (Spain) */
    { "BPES", { Config::BackupType::FLASH_128, GPIODeviceType::RTC, false } },  /* Pokemon - Edicion Esmeralda (Spain) */
    { "BPGS", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }, /* Pokemon - Edicion Verde Hoja (Spain) */
    { "BPRS", { Config::BackupType::FLASH_128, GPIODeviceType::None, false } }  /* Pokemon - Edicion Rojo Fuego (Spain) */,
    { "A9DP", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* DOOM II */
    { "AAOJ", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* Acrobat Kid (Japan) */
    { "BGDP", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* Baldur's Gate - Dark Alliance (Europe) */
    { "BGDE", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* Baldur's Gate - Dark Alliance (USA) */
    { "BJBE", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* 007 - Everything or Nothing (USA, Europe) (En,Fr,De) */
    { "BJBJ", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* 007 - Everything or Nothing (Japan) */
    { "ALUP", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* 0937 - Super Monkey Ball Jr. (Europe) */
    { "ALUE", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } },  /* 0763 - Super Monkey Ball Jr. (USA) */
    { "BL8E", { Config::BackupType::EEPROM_4, GPIODeviceType::None, false } }   /* 2561 - Tomb Raider - Legend  */
};

using BackupType = Config::BackupType;

static constexpr size_t kMaxROMSize = 32 * 1024 * 1024; // 32 MiB

auto ROMLoader::Load(std::unique_ptr<System>& core, std::filesystem::path const& path,
                     Config::BackupType backup_type, GPIODeviceType force_gpio) -> Result {
    const auto save_path = fs::path{path}.replace_extension(".sav");
    return Load(core, path, save_path, backup_type, force_gpio);
}

auto ROMLoader::Load(std::unique_ptr<System>& core, std::filesystem::path const& rom_path, std::filesystem::path const& save_path,
                     BackupType backup_type, GPIODeviceType force_gpio ) -> Result {
    auto file_data = std::vector<u8>{};
    auto read_status = ReadFile(rom_path, file_data);
    
    if(read_status != Result::Success) {
        return read_status;
    }
    
    auto size = file_data.size();
    
    if(size < sizeof(Header) || size > kMaxROMSize) {
        return Result::BadImage;
    }
    
    auto game_info = GetGameInfo(file_data);
    
    if(backup_type == BackupType::Detect) {
        if(game_info.backup_type != BackupType::Detect) {
            backup_type = game_info.backup_type;
        } else {
            backup_type = GetBackupType(file_data);
            if(backup_type == BackupType::Detect) {
                Log<Warn>("ROMLoader: failed to detect backup type!");
                backup_type = BackupType::SRAM;
            }
        }
    }
    
    auto backup = CreateBackup(core, save_path, backup_type);
    
    auto gpio = std::unique_ptr<GPIO>{};
    
    auto gpio_devices = game_info.gpio | force_gpio;
    
    if(gpio_devices != GPIODeviceType::None) {
        gpio = std::make_unique<GPIO>();
        
        if(gpio_devices & GPIODeviceType::RTC) {
            gpio->Attach(core->CreateRTC());
        }
        
        if(gpio_devices & GPIODeviceType::SolarSensor) {
            gpio->Attach(core->CreateSolarSensor());
        }
    }
    
    u32 rom_mask = u32(kMaxROMSize - 1);
    if(game_info.mirror) {
        rom_mask = u32(RoundSizeToPowerOfTwo(size) - 1);
    }
    
    core->Attach(ROM{
        std::move(file_data),
        std::move(backup),
        std::move(gpio),
        rom_mask
    });
    return Result::Success;
}

auto ROMLoader::ReadFile(std::filesystem::path const& path, std::vector<u8>& file_data) -> Result {
    if(!std::filesystem::exists(path)) {
        return Result::CannotFindFile;
    }
    
    if(std::filesystem::is_directory(path)) {
        return Result::CannotOpenFile;
    }
    
    auto file_stream = std::ifstream{path, std::ios::binary};
    
    if(!file_stream.good()) {
        return Result::CannotOpenFile;
    }
    
    auto file_size = std::filesystem::file_size(path);
    
    file_data.resize(file_size);
    file_stream.read((char*)file_data.data(), file_size);
    return Result::Success;
}

auto ROMLoader::GetGameInfo(
                            std::vector<u8>& file_data
                            ) -> GameInfo {
                                auto header = reinterpret_cast<Header*>(file_data.data());
                                auto game_code = std::string{};
                                game_code.assign(header->game.code, 4);
                                
                                auto db_entry = g_game_db.find(game_code);
                                if(db_entry != g_game_db.end()) {
                                    return db_entry->second;
                                }
                                
                                return GameInfo{};
                            }

auto ROMLoader::GetBackupType(
                              std::vector<u8>& file_data
                              ) -> BackupType {
                                  static constexpr std::pair<std::string_view, BackupType> signatures[6] {
                                      { "EEPROM_V",   BackupType::EEPROM_DETECT },
                                      { "SRAM_V",     BackupType::SRAM },
                                      { "SRAM_F_V",   BackupType::SRAM },
                                      { "FLASH_V",    BackupType::FLASH_64 },
                                      { "FLASH512_V", BackupType::FLASH_64 },
                                      { "FLASH1M_V",  BackupType::FLASH_128 }
                                  };
                                  
                                  const auto size = file_data.size();
                                  
                                  for(int i = 0; i < size; i += sizeof(u32)) {
                                      for(auto const& [signature, type] : signatures) {
                                          if((i + signature.size()) <= size &&
                                             std::memcmp(&file_data[i], signature.data(), signature.size()) == 0) {
                                              return type;
                                          }
                                      }
                                  }
                                  
                                  return BackupType::Detect;
                              }

auto ROMLoader::CreateBackup(
                             std::unique_ptr<System>& core,
                             std::filesystem::path const& save_path,
                             BackupType backup_type
                             ) -> std::unique_ptr<Backup> {
                                 switch(backup_type) {
                                     case BackupType::SRAM:      return std::make_unique<SRAM>(save_path);
                                     case BackupType::FLASH_64:  return std::make_unique<FLASH>(save_path, FLASH::SIZE_64K);
                                     case BackupType::FLASH_128: return std::make_unique<FLASH>(save_path, FLASH::SIZE_128K);
                                     case BackupType::EEPROM_4:  return std::make_unique<EEPROM>(save_path, EEPROM::SIZE_4K, core->GetScheduler());
                                     case BackupType::EEPROM_64: return std::make_unique<EEPROM>(save_path, EEPROM::SIZE_64K, core->GetScheduler());
                                     case BackupType::EEPROM_DETECT: return std::make_unique<EEPROM>(save_path, EEPROM::DETECT, core->GetScheduler());
                                     default: break;
                                 }
                                 
                                 return {};
                             }

auto ROMLoader::RoundSizeToPowerOfTwo(size_t size) -> size_t {
    size_t pot_size = 1;
    
    while(pot_size < size) {
        pot_size *= 2;
    }
    
    return pot_size;
}
}


nba::SWVideoDevice::~SWVideoDevice() {}

void nba::SWVideoDevice::Draw(u32* buffer) {
    tomato::callback(tomato::context, buffer);
}


struct CPPTomato {
    TomatoCommon tomatoCommon{TomatoCommon::init()};
    TomatoSystem tomatoSystem{TomatoSystem::init()};
    
    std::shared_ptr<nba::Config> config;
    std::unique_ptr<System> system;
    std::unique_ptr<nba::EmulatorThread> thread;
    
    std::filesystem::path tomato_path, memory_cards_path, system_data_path;
} cppTomato;

void tomato::print_about(void) {
    printf("Welcome to Tomato\n");
    printf("Game Boy Advance emulator based on NanoBoyAdvance\n");
}


void tomato::initialize_system(void) {
    cppTomato.config = std::make_shared<nba::Config>();
    cppTomato.config->video_dev = std::make_shared<nba::SWVideoDevice>();
    
    cppTomato.system = nba::CreateCore(cppTomato.config);
    cppTomato.thread = std::make_unique<nba::EmulatorThread>();
}


void tomato::initialize_paths(void) {
    auto tomatoDirectoryURL{cppTomato.tomatoCommon.getTomatoDirectoryURL()};
    if (tomatoDirectoryURL.isSome()) {
        auto tomato_path{std::filesystem::path{tomatoDirectoryURL.get()}};
        
        cppTomato.tomato_path = tomato_path;
        cppTomato.system_data_path = tomato_path / "system_data";
        printf("%s\n", tomato_path.string().c_str());
    }
    
    auto bios = cppTomato.system_data_path / "bios.bin";
    
    nba::BIOSLoader::Load(cppTomato.system, bios.string());
}

void tomato::destroy_system(void) {
    tomato::initialize_system();
}


void tomato::insert_disc(std::string path) {
    nba::ROMLoader::Load(cppTomato.system, path); // TODO: make fs::path
}


bool tomato::is_paused(bool change, bool set_paused) {
    if (change)
        cppTomato.thread->SetPause(set_paused);
    return cppTomato.thread->IsPaused();
}

bool tomato::is_running(bool change, bool set_running) {
    return cppTomato.thread->IsRunning();
}


void tomato::start(void) {
    cppTomato.thread->Start(std::move(cppTomato.system));
}

void tomato::stop(void) {
    cppTomato.thread->Stop();
}


int tomato::framebuffer_height(void) {
    return 160;
}

int tomato::framebuffer_width(void) {
    return 240;
}


void tomato::video_buffer_callback(tomato::VideoBufferCallback callback) {
    tomato::callback = callback;
}


void tomato::press_button(uint8_t button) {
    cppTomato.thread->SetKeyStatus(static_cast<nba::Key>(button), true);
}

void tomato::release_button(uint8_t button) {
    cppTomato.thread->SetKeyStatus(static_cast<nba::Key>(button), false);
}


void tomato::set_context(void* context) {
    tomato::context = context;
}
