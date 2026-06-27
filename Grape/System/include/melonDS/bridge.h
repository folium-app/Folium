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

bool is_paused(bool = false, bool = false);
bool is_running(bool = false, bool = false);

void press_button(uint32_t), release_button(uint32_t);
}
