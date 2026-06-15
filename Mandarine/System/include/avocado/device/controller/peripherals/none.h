#pragma once
#include <string>
#include "avocado/device/controller/peripherals/abstract_device.h"
#include "avocado/device/device.h"

namespace peripherals {
struct None : public AbstractDevice {
    None(int port);
    uint8_t handle(uint8_t byte) override;
};
};  // namespace peripherals
