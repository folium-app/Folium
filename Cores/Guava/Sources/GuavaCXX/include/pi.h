#pragma once

#include "common/types.h"

class MMU;

class PI {
public:
    explicit PI(MMU& mmu) : m_mmu(mmu) {}

    u32 dram_address() const { return m_dram_address; }
    void set_dram_address(u32 address) { m_dram_address = address; }

    u32 dma_cart_address() const { return m_dma_cart_address; }
    void set_dma_cart_address(u32 address) { m_dma_cart_address = address; }

    void set_dma_write_length(u32 value) {
        m_dma_write_length = value + 1;
        run_dma_transfer_to_rdram();
    }

    [[nodiscard]] u32 status() const { return m_status; }

private:
    MMU& m_mmu;

    u32 m_dram_address {};
    u32 m_dma_cart_address {};
    u32 m_dma_write_length {};
    u32 m_status {};

    void run_dma_transfer_to_rdram();
};
