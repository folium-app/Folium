#pragma once
#include "avocado/device/dma/dma_channel.h"

namespace device::dma {
class DMA5Channel : public DMAChannel {
   public:
    DMA5Channel(Channel channel, System* sys);
};
}  // namespace device::dma
