#pragma once

#include <array>
#include "common/types.h"
#include "mi.h"
#include "pi.h"
#include "si.h"
#include "vi.h"

class N64;

class MMU {
public:
    explicit MMU(N64& system);

    enum class AddressRanges {
        User,
        Kernel0,
        Kernel1,
        KernelSupervisor,
        Kernel3,
    };
    
    static constexpr AddressRanges address_range(u32 address);
    static constexpr u32 virtual_address_to_physical_address(u32 address);

    u8 read8(u32 address);
    void write8(u32 address, u8 value);
    u16 read16(u32 address);
    void write16(u32 address, u16 value);
    u32 read32(u32 address);
    void write32(u32 address, u32 value);
    u64 read64(u32 address);
    void write64(u32 address, u64 value);

    template <typename T>
    T read(u32 address);
    template <typename T>
    void write(u32 address, T value);

    MI& mi() { return m_mi; }
    const MI& mi() const { return m_mi; }
    VI& vi() { return m_vi; }
    const VI& vi() const { return m_vi; }

    const auto& rdram() const { return m_rdram; }

private:
    N64& m_system;
    PI m_pi;
    MI m_mi;
    VI m_vi;
    SI m_si;

    std::array<u8, 0x400000> m_rdram {};
    std::array<u8, 0x1000> m_sp_dmem {};
    std::array<u8, 0x1000> m_sp_imem {};
    std::array<u8, 0x200> m_isviewer_buffer {};
    std::array<u8, 0x40> m_pif_ram {};
};
