//
//  bridge.cpp
//  Grape
//
//  Created by Jarrod Norwell on 28/6/2026.
//

#include "melonDS/bridge.h"

#include "Grape-Swift.h"
using namespace Grape;

#include <_printf.h>
#include <algorithm>
#include <filesystem>
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

void grape::print_about(void) {
    auto grape = GrapeCommon::init();
    
    printf("Welcome to Grape\n");
    printf("Nintendo DS emulator based on melonDS\n");
    printf("Grape Directory: %s\n", std::filesystem::path{grape.getGrapeDirectoryURL().get()}.c_str());
}

uint32_t* grape::icon_from_disc(std::string path) {
    auto disc_path{std::filesystem::path{path}};
    NDSIcon icon{disc_path};
    return icon.icon_buffer();
}

bool grape::is_paused(bool change, bool set_paused) {
    return true;
}

bool grape::is_running(bool change, bool set_running) {
    return true;
}

void grape::press_button(uint32_t button) {
    
}

void grape::release_button(uint32_t button) {
    
}
