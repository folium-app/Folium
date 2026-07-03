//
//  bridge.h
//  Grape
//
//  Created by Jarrod Norwell on 28/6/2026.
//

#include <cstdint>
#include <string>

namespace grape {
void print_about(void);

uint32_t* icon_from_disc(std::string);

void initialize_paths(void);
void initialize_system(void);

void destroy_system(void);

void insert_disc(std::string);

bool is_paused(bool = false, bool = false);
bool is_running(bool = false, bool = false);

void start(void), stop(void);

int framebuffer_height(void), framebuffer_width(void);

using VideoBufferCallback = void(*)(void*, uint32_t*, uint32_t*);
VideoBufferCallback callback;
void video_buffer_callback(VideoBufferCallback);

void press_button(uint32_t), release_button(uint32_t);
void touch_began(uint16_t, uint16_t), touch_ended(void), touch_moved(uint16_t, uint16_t);

void* context;
void set_context(void* context);
}
