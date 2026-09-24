//
//  mesence.h
//  MesenCE
//
//  Created by Jarrod Norwell on 9/9/2026.
//

#pragma once

#include "Emulator.h"
#include "Gameboy/Input/GbController.h"
#include "GBA/Input/GbaController.h"
#include "NES/Input/NesController.h"
#include "SNES/Input/SnesController.h"
#include "WS/Input/WsController.h"
#include "Shared/Audio/BaseSoundManager.h"
#include "Shared/Interfaces/IInputProvider.h"
#include "Shared/Interfaces/IMessageManager.h"
#include "Shared/Interfaces/IRenderingDevice.h"

#include <memory>

#include <SDL3/SDL.h>

struct nes {
    static constexpr uint32_t kNesOverscanLeft = 8;
    static constexpr uint32_t kNesPalette2C02[64] = {
        0xFF666666, 0xFF002A88, 0xFF1412A7, 0xFF3B00A4, 0xFF5C007E, 0xFF6E0040, 0xFF6C0600, 0xFF561D00,
        0xFF333500, 0xFF0B4800, 0xFF005200, 0xFF004F08, 0xFF00404D, 0xFF000000, 0xFF000000, 0xFF000000,
        0xFFADADAD, 0xFF155FD9, 0xFF4240FF, 0xFF7527FE, 0xFFA01ACC, 0xFFB71E7B, 0xFFB53120, 0xFF994E00,
        0xFF6B6D00, 0xFF388700, 0xFF0C9300, 0xFF008F32, 0xFF007C8D, 0xFF000000, 0xFF000000, 0xFF000000,
        0xFFFFFEFF, 0xFF64B0FF, 0xFF9290FF, 0xFFC676FF, 0xFFF36AFF, 0xFFFE6ECC, 0xFFFE8170, 0xFFEA9E22,
        0xFFBCBE00, 0xFF88D800, 0xFF5CE430, 0xFF45E082, 0xFF48CDDE, 0xFF4F4F4F, 0xFF000000, 0xFF000000,
        0xFFFFFEFF, 0xFFC0DFFF, 0xFFD3D2FF, 0xFFE8C8FF, 0xFFFBC2FF, 0xFFFEC4EA, 0xFFFECCC5, 0xFFF7D8A5,
        0xFFE4E594, 0xFFCFEF96, 0xFFBDF4AB, 0xFFB3F3CC, 0xFFB5EBF2, 0xFFB8B8B8, 0xFF000000, 0xFF000000
    };
};

struct snes {
    static constexpr uint32_t kSnesOverscanTop = 7;
    static constexpr uint32_t kSnesOverscanBottom = 8;
};

class iOSMessageManager final : public IMessageManager {
public:
    void DisplayMessage(string title, string message) override {
        printf("[%s]: %s\n", title.c_str(), message.c_str());
    }
};

class iOSRenderer : public IRenderingDevice {
public:
    explicit iOSRenderer(std::unique_ptr<Emulator>&, uint32_t, uint32_t);
    ~iOSRenderer() override;
    
    void UpdateFrame(RenderedFrame&) override;
    void ClearFrame() override;
    void Render(RenderSurfaceInfo&, RenderSurfaceInfo&) override;
    void Reset() override {}
    
    void SetFullscreenMode(FullscreenSettings) override {};
    
    bool GetFrameIfReady(std::vector<uint32_t>&, uint32_t&, uint32_t&);
private:
    std::unique_ptr<Emulator>& emulator;
    
    std::atomic<bool> dirty;
    std::pair<std::atomic<uint32_t>, std::atomic<uint32_t>> dimensions;
    std::mutex mutex;
    std::pair<std::vector<uint32_t>, std::vector<uint32_t>> buffers;
};

class iOSSink : public BaseSoundManager {
public:
    explicit iOSSink(std::unique_ptr<Emulator>&, uint32_t = -1);
    ~iOSSink();
    
    void Pause() override;
    void Play(int16_t*, uint32_t, uint32_t, bool);
    void PlayBuffer(int16_t* out_b, uint32_t sample_count, uint32_t sample_rate, bool stereo) override {
        Play(out_b, sample_count, sample_rate, stereo);
    };
    void Stop() override;
    
    void ProcessEndOfFrame() override;
private:
    bool Initialize(uint32_t, bool);
    void Release();

    static void Callback(void*, SDL_AudioStream*, int, int);

    void ReadFromBuffer(uint8_t*, uint32_t);
    void WriteToBuffer(uint8_t*, uint32_t);
    
    std::string GetAvailableDevices() override { return {}; };
    void SetAudioDevice(std::string) override {};

private:
    std::unique_ptr<Emulator>& emulator;
    
    SDL_AudioStream* stream;
    
    uint32_t audio_latency;
    
    std::pair<uint32_t, uint32_t> positions;
    std::vector<uint8_t> buffer;
};

// MARK: GB Input
class GBInput : public IInputProvider {
public:
    std::atomic<uint32_t> keys{0};
    
    bool SetInput(BaseControlDevice* device) override {
        if(device->GetPort() != 0)
            return false;

        uint32_t loaded_keys{keys.load()};
        device->SetBitValue(GbController::Buttons::A, loaded_keys & 0x001);
        device->SetBitValue(GbController::Buttons::B, loaded_keys & 0x002);
        device->SetBitValue(GbController::Buttons::Select, loaded_keys & 0x004);
        device->SetBitValue(GbController::Buttons::Start, loaded_keys & 0x008);
        device->SetBitValue(GbController::Buttons::Right, loaded_keys & 0x010);
        device->SetBitValue(GbController::Buttons::Left, loaded_keys & 0x020);
        device->SetBitValue(GbController::Buttons::Up, loaded_keys & 0x040);
        device->SetBitValue(GbController::Buttons::Down, loaded_keys & 0x080);
        return true;
    }
};

// MARK: GBA Input
class GBAInput : public IInputProvider {
public:
    std::atomic<uint32_t> keys{0};
    
    bool SetInput(BaseControlDevice* device) override {
        if(device->GetPort() != 0)
            return false;

        uint32_t loaded_keys{keys.load()};
        device->SetBitValue(GbaController::Buttons::A, loaded_keys & 0x001);
        device->SetBitValue(GbaController::Buttons::B, loaded_keys & 0x002);
        device->SetBitValue(GbaController::Buttons::Select, loaded_keys & 0x004);
        device->SetBitValue(GbaController::Buttons::Start, loaded_keys & 0x008);
        device->SetBitValue(GbaController::Buttons::Right, loaded_keys & 0x010);
        device->SetBitValue(GbaController::Buttons::Left, loaded_keys & 0x020);
        device->SetBitValue(GbaController::Buttons::Up, loaded_keys & 0x040);
        device->SetBitValue(GbaController::Buttons::Down, loaded_keys & 0x080);
        device->SetBitValue(GbaController::Buttons::R, loaded_keys & 0x100);
        device->SetBitValue(GbaController::Buttons::L, loaded_keys & 0x200);
        return true;
    }
};

// MARK: NES Input
class NESInput : public IInputProvider {
public:
    std::atomic<uint32_t> keys{0};
    
    bool SetInput(BaseControlDevice* device) override {
        if(device->GetPort() != 0)
            return false;

        uint32_t loaded_keys{keys.load()};
        device->SetBitValue(NesController::Buttons::A, loaded_keys & 0x001);
        device->SetBitValue(NesController::Buttons::B, loaded_keys & 0x002);
        device->SetBitValue(NesController::Buttons::Select, loaded_keys & 0x004);
        device->SetBitValue(NesController::Buttons::Start, loaded_keys & 0x008);
        device->SetBitValue(NesController::Buttons::Right, loaded_keys & 0x010);
        device->SetBitValue(NesController::Buttons::Left, loaded_keys & 0x020);
        device->SetBitValue(NesController::Buttons::Up, loaded_keys & 0x040);
        device->SetBitValue(NesController::Buttons::Down, loaded_keys & 0x080);
        return true;
    }
};

// MARK: SNES Input
class SNESInput : public IInputProvider {
public:
    std::atomic<uint32_t> keys{0};
    
    bool SetInput(BaseControlDevice* device) override {
        if(device->GetPort() != 0)
            return false;

        uint32_t loaded_keys{keys.load()};
        device->SetBitValue(SnesController::Buttons::A, loaded_keys & 0x001);
        device->SetBitValue(SnesController::Buttons::B, loaded_keys & 0x002);
        device->SetBitValue(SnesController::Buttons::Select, loaded_keys & 0x004);
        device->SetBitValue(SnesController::Buttons::Start, loaded_keys & 0x008);
        device->SetBitValue(SnesController::Buttons::Right, loaded_keys & 0x010);
        device->SetBitValue(SnesController::Buttons::Left, loaded_keys & 0x020);
        device->SetBitValue(SnesController::Buttons::Up, loaded_keys & 0x040);
        device->SetBitValue(SnesController::Buttons::Down, loaded_keys & 0x080);
        device->SetBitValue(SnesController::Buttons::R, loaded_keys & 0x100);
        device->SetBitValue(SnesController::Buttons::L, loaded_keys & 0x200);
        device->SetBitValue(SnesController::Buttons::X, loaded_keys & 0x400);
        device->SetBitValue(SnesController::Buttons::Y, loaded_keys & 0x800);
        return true;
    }
};

// MARK: WS Input
class WSInput : public IInputProvider {
public:
    std::atomic<uint32_t> keys{0};
    
    bool SetInput(BaseControlDevice* device) override {
        if(device->GetPort() != 0)
            return false;

        uint32_t loaded_keys{keys.load()};
        device->SetBitValue(WsController::Buttons::Up, loaded_keys & 0x001);
        device->SetBitValue(WsController::Buttons::Down, loaded_keys & 0x002);
        device->SetBitValue(WsController::Buttons::Left, loaded_keys & 0x004);
        device->SetBitValue(WsController::Buttons::Right, loaded_keys & 0x008);
        
        device->SetBitValue(WsController::Buttons::Up2, loaded_keys & 0x010);
        device->SetBitValue(WsController::Buttons::Down2, loaded_keys & 0x020);
        device->SetBitValue(WsController::Buttons::Left2, loaded_keys & 0x040);
        device->SetBitValue(WsController::Buttons::Right2, loaded_keys & 0x080);
        
        device->SetBitValue(WsController::Buttons::Sound, loaded_keys & 0x100);
        device->SetBitValue(WsController::Buttons::Start, loaded_keys & 0x200);
        
        device->SetBitValue(WsController::Buttons::B, loaded_keys & 0x400);
        device->SetBitValue(WsController::Buttons::A, loaded_keys & 0x800);
        return true;
    }
};
