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
    SOUND_ENABLED = 2,
    EXTENDED_MEMORY = 3
};

void set_setting(SETTING, bool);
}
