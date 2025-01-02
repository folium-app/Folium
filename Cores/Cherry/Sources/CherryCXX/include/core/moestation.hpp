/*
 * moestation is a WIP PlayStation 2 emulator.
 * Copyright (C) 2022-2023  Lady Starbreeze (Michelle-Marie Schiller)
 */

#pragma once

#include "common/types.hpp"

namespace ps2 {
void set_path(const char*);
void enterPS1Mode();
void fastBoot();
}

extern void update(uint32_t* fb);
