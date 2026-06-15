#pragma once
#include "avocado/device/device.h"

class Serial {
    static const uint32_t BASE_ADDRESS = 0x1F801050;
    Reg32 status;
    Reg16 baud;

   public:
    Serial();
    void reset();
    void step();
    uint8_t read(uint32_t address);
    void write(uint32_t address, uint8_t data);

    template <class Archive>
    void serialize(Archive& ar) {
        ar(status, baud);
    }
};
