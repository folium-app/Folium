#include "common/bits.h"
#include "common/logging.h"
#include "mmu.h"
#include "pi.h"

void PI::run_dma_transfer_to_rdram() {
    LINFO("PI DMA: writing {:08X} bytes from {:08X} to {:08X}", m_dma_write_length, m_dma_cart_address, m_dram_address);
    for (u32 i = 0; i < m_dma_write_length; i++) {
        try {
            m_mmu.write8(m_dram_address + i, m_mmu.read8(m_dma_cart_address + i));
        } catch (...) {
            LERROR("Read outside ROM bounds during PI DMA transfer, copied {}/{} bytes", i, m_dma_write_length);
            break;
        }
    }

    Common::enable_bits<3>(m_status);
    m_mmu.mi().request_interrupt(MI::InterruptFlags::PI);
}
