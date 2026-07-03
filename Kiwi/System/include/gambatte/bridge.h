//
//  bridge.h
//  Kiwi
//
//  Created by Jarrod Norwell on 2/7/2026.
//

#include <cstdint>
#include <string>

namespace kiwi {
void print_about(void);

void initialize_paths(void);
void initialize_system(void);

void destroy_system(void);

void insert_disc(std::string);

bool is_paused(bool = false, bool = false);
bool is_running(bool = false, bool = false);

void start(void), stop(void);

int framebuffer_height(void), framebuffer_width(void);

using AudioVideoBufferCallback = void(*)(void*, uint32_t*, size_t);
AudioVideoBufferCallback audio_callback;
void audio_buffer_callback(AudioVideoBufferCallback);

AudioVideoBufferCallback video_callback;
void video_buffer_callback(AudioVideoBufferCallback);

void press_button(uint32_t), release_button(uint32_t);

void* context;
void set_context(void* context);
}
