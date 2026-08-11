//
//  bridge.h
//  Cherry
//
//  Created by Jarrod Norwell on 9/8/2026.
//

#pragma once

#include <cstdint>
#include <functional>
#include <string>

namespace cherry {
void print_about(void);

void initialize_paths(void);
void initialize_system(void);

void destroy_system(void);

void insert_disc(std::string);

bool is_paused(bool = false, bool = false);
bool is_running(bool = false, bool = false);

void start(void);
void stop(void);

int framebuffer_height(void), framebuffer_width(void);

using VideoBufferCallback = void(*)(void*, uint8_t*);
VideoBufferCallback video_callback;
void video_buffer_callback(VideoBufferCallback);

void press_button(int, int), release_button(int, int);

void* context;
void set_context(void* context);
}
