//
//  bridge.h
//  Mandarine
//
//  Created by Jarrod Norwell on 14/6/2026.
//

#include <cstdint>
#include <functional>
#include <string>

namespace mandarine {
void print_about(void);

std::string disc_identifier(std::string);

void initialize_paths(void);
void initialize_memory_cards(void);
void initialize_system(void);

void destroy_system(void);

void insert_disc(std::string);

bool is_paused(bool = false, bool = false);
bool is_running(bool = false, bool = false);

void start(void);
void stop(void);

int16_t framebuffer_start_x(void), framebuffer_start_y(void);
int framebuffer_height(void), framebuffer_width(void);

using VideoBufferCallback15Bit = void(*)(void*, void*);
VideoBufferCallback15Bit callback_15bit;
void video_buffer_callback_15bit(VideoBufferCallback15Bit);

using VideoBufferCallback24Bit = void(*)(void*, uint16_t*);
VideoBufferCallback24Bit callback_24bit;
void video_buffer_callback_24bit(VideoBufferCallback24Bit);

void press_button(std::string, int), release_button(std::string, int);
void drag_thumbstick(std::string, uint8_t);

void* context;
void set_context(void* context);

enum class SETTING {
    WIDESCREEN = 0,
    FORCE_WIDESCREEN = 1,
    VSYNC = 2,
    FORCE_NTSC = 3,
    NATIVE_TEXTURE_FORMAT = 4,
    SOUND_ENABLED = 5,
    PRESERVE_STATE = 6,
    TIME_TRAVEL = 7,
    EXTENDED_MEMORY = 8,
    
    LOG_BIOS = 9,
    LOG_CDROM = 10,
    LOG_CONTROLLER = 11,
    LOG_DMA = 12,
    LOG_GPU = 13,
    LOG_GTE = 14,
    LOG_MDEC = 15,
    LOG_MEMORY_CARD = 16,
    LOG_MEMORY_CONTROL = 17,
    LOG_SPU = 18,
    LOG_SYSTEM = 19
};

void set_setting(SETTING, bool);
}
