#include "gambatte/video/next_m0_time.h"
#include "gambatte/video/ppu.h"

void gambatte::NextM0Time::predictNextM0Time(PPU const &ppu) {
	predictedNextM0Time_ = ppu.predictedNextXposTime(167);
}
