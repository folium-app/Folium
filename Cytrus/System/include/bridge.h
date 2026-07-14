//
//  bridge.h
//  Cytrus
//
//  Created by Jarrod Norwell on 13/7/2026.
//

#include <cstdint>
#include <string>

namespace cytrus {
void print_about(void);

void initialize_logging(void);

void* icon_from_disc(std::string);

void insert_disc(std::string);

bool is_paused(bool = false, bool = false);
bool is_running(bool = false, bool = false);

void start(void), stop(void);

void set_screens(void*, double, double, bool);

void press_button(int), release_button(int);
void touch_began(float, float), touch_ended(void), touch_moved(float, float);
}
