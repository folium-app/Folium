#include "si.h"
#include "mmu.h"

void SI::transfer_64_bytes_from_pif_ram(const u32 source_address) {
    for (std::size_t i = 0; i < 64; i += sizeof(u32)) {
        m_mmu.write32(m_dram_address + i, m_mmu.read32(source_address + i));
    }

    m_mmu.mi().request_interrupt(MI::InterruptFlags::SI);
}

void SI::transfer_64_bytes_to_pif_ram(const u32 destination_address) {
    for (std::size_t i = 0; i < 64; i += sizeof(u32)) {
        m_mmu.write32(destination_address + i, m_mmu.read32(m_dram_address + i));
    }

    m_mmu.mi().request_interrupt(MI::InterruptFlags::SI);
}
