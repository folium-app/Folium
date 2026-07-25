//
//  constants.h
//  Folium
//
//  Created by Jarrod Norwell on 24/7/2026.
//

#pragma once

namespace constants {

namespace bios {
constexpr int BASE = 0x1FC00000;
constexpr int SIZE = 0x80000;
};

namespace cpu {
constexpr int REGISTER_SIZE = 38; // 32 gprs + epc, pc, npc, hi, lo
};

namespace expansion {
constexpr int REGION_1_BASE = 0x1F000000;
constexpr int REGION_1_SIZE = 0x80000;

constexpr int REGION_2_BASE = 0x1F802000;
constexpr int REGION_2_SIZE = 128;

constexpr int REGION_3_BASE = 0x1FA00000;
constexpr int REGION_3_SIZE = 1;
};

// unused
namespace io {
constexpr int MEMORY_CONTROL_START = 0x1F801000;
constexpr int MEMORY_CONTROL_END = 0x1F801024;

constexpr int CONTROLLER_START = 0x1F801040;
constexpr int CONTROLLER_END = 0x1F801050;

constexpr int SERIAL_START = 0x1F801050;
constexpr int SERIAL_END = 0x1F801060;

constexpr int RAM_CONTROL_START = 0x1F801060;
constexpr int RAM_CONTROL_END = 0x1F801064;

constexpr int INTERRUPT_START = 0x1F801070;
constexpr int INTERRUPT_END = 0x1F801078;

constexpr int DMA_START = 0x1F801080;
constexpr int DMA_END = 0x1F801100;

constexpr int TIMER_1_START = 0x1F801100;
constexpr int TIMER_1_END = 0x1F801110;

constexpr int TIMER_2_START = 0x1F801110;
constexpr int TIMER_2_END = 0x1F801120;

constexpr int TIMER_3_START = 0x1F801120;
constexpr int TIMER_3_END = 0x1F801130;

constexpr int CDROM_START = 0x1F801800;
constexpr int CDROM_END = 0x1F801804;

constexpr int SPU_START = 0x1F801C00;
constexpr int SPU_END = 0x1F802000;

constexpr int EXPANSION_2_START = 0x1F802000;
constexpr int EXPANSION_2_END = 0x1F804000;

// constexpr int BASE = 0x1F801000;
// constexpr int SIZE = 0x00002000;
};

namespace ram {
constexpr int BASE = 0;
constexpr int SIZE_2MB = 0x200000;
constexpr int SIZE_8MB = 0x800000;
};

namespace scratchpad {
constexpr int BASE = 0x1F800000;
constexpr int SIZE = 0x400;
};

namespace timers {
constexpr int SIZE = 3;
};

}
