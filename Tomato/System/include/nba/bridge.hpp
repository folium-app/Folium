//
//  bridge.h
//  Tomato
//
//  Created by Jarrod Norwell on 21/6/2026.
//

#include <cstdint>
#include <string>

namespace tomato {
void print_about(void);

void initialize_paths(void);
void initialize_system(void);

void destroy_system(void);

void insert_disc(std::string);

bool is_paused(bool = false, bool = false);
bool is_running(bool = false, bool = false);

void start(void), stop(void);

int framebuffer_height(void), framebuffer_width(void);

using VideoBufferCallback = void(*)(void*, uint32_t*);
VideoBufferCallback callback;
void video_buffer_callback(VideoBufferCallback);

void press_button(uint8_t), release_button(uint8_t);

void* context;
void set_context(void* context);
}
