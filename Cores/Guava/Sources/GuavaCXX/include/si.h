#pragma once

#include "common/types.h"

class MMU;

class SI {
public:
    explicit SI(MMU& mmu) : m_mmu(mmu) {}

    u32 dram_address() const { return m_dram_address; }
    void set_dram_address(u32 address) { m_dram_address = address; }

    [[nodiscard]] u32 status() const { return m_status; }

    void transfer_64_bytes_from_pif_ram(u32 source_address);
    void transfer_64_bytes_to_pif_ram(u32 destination_address);

private:
    MMU& m_mmu;

    u32 m_dram_address {};
    u32 m_status {};
};
