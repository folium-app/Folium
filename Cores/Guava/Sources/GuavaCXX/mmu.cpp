#include "common/bits.h"
#include "common/logging.h"
#include "mmu.h"
#include "n64.h"

static constexpr u32 KUSEG_BASE = 0x00000000;
static constexpr u32 KSEG0_BASE = 0x80000000;
static constexpr u32 KSEG1_BASE = 0xA0000000;
static constexpr u32 KSSEG_BASE = 0xC0000000;
static constexpr u32 KSEG3_BASE = 0xE0000000;

static constexpr u32 RDRAM_BUILTIN_BASE        = 0x00000000;
static constexpr u32 RDRAM_BUILTIN_END         = 0x003FFFFF;

static constexpr u32 RDRAM_EXPANSION_BASE      = 0x00400000;
static constexpr u32 RDRAM_EXPANSION_END       = 0x007FFFFF;

static constexpr u32 RDRAM_REGISTERS_BASE      = 0x03F00000;
static constexpr u32 RDRAM_REGISTERS_END       = 0x03FFFFFF;

static constexpr u32 SP_DMEM_BASE              = 0x04000000;
static constexpr u32 SP_DMEM_END               = 0x04000FFF;

static constexpr u32 SP_IMEM_BASE              = 0x04001000;
static constexpr u32 SP_IMEM_END               = 0x04001FFF;

static constexpr u32 SP_REGISTERS_BASE         = 0x04040000;
static constexpr u32 SP_REGISTERS_END          = 0x040FFFFF;

static constexpr u32 DP_COMMAND_REGISTERS_BASE = 0x04100000;
static constexpr u32 DP_COMMAND_REGISTERS_END  = 0x041FFFFF;

static constexpr u32 DP_SPAN_REGISTERS_BASE    = 0x04200000;
static constexpr u32 DP_SPAN_REGISTERS_END     = 0x042FFFFF;

static constexpr u32 MI_REGISTERS_BASE         = 0x04300000;
static constexpr u32 MI_REG_MODE               = 0x04300000;
static constexpr u32 MI_REG_VERSION            = 0x04300004;
static constexpr u32 MI_REG_INTR               = 0x04300008;
static constexpr u32 MI_REG_INTR_MASK          = 0x0430000C;
static constexpr u32 MI_REGISTERS_END          = 0x043FFFFF;

static constexpr u32 VI_REGISTERS_BASE         = 0x04400000;
static constexpr u32 VI_REG_CONTROL            = 0x04400000;
static constexpr u32 VI_REG_ORIGIN             = 0x04400004;
static constexpr u32 VI_REG_WIDTH              = 0x04400008;
static constexpr u32 VI_REG_V_INTR             = 0x0440000C;
static constexpr u32 VI_REG_V_CURRENT          = 0x04400010;
static constexpr u32 VI_REG_BURST              = 0x04400014;
static constexpr u32 VI_REG_V_SYNC             = 0x04400018;
static constexpr u32 VI_REG_H_SYNC             = 0x0440001C;
static constexpr u32 VI_REG_LEAP               = 0x04400020;
static constexpr u32 VI_REG_H_START            = 0x04400024;
static constexpr u32 VI_REG_V_START            = 0x04400028;
static constexpr u32 VI_REG_V_BURST            = 0x0440002C;
static constexpr u32 VI_REG_X_SCALE            = 0x04400030;
static constexpr u32 VI_REG_Y_SCALE            = 0x04400034;
static constexpr u32 VI_REGISTERS_END          = 0x044FFFFF;

static constexpr u32 AI_REGISTERS_BASE         = 0x04500000;
static constexpr u32 AI_REGISTERS_END          = 0x045FFFFF;

static constexpr u32 PI_REGISTERS_BASE         = 0x04600000;
static constexpr u32 PI_REG_DRAM_ADDRESS       = 0x04600000;
static constexpr u32 PI_REG_DMA_CART_ADDRESS   = 0x04600004;
static constexpr u32 PI_REG_DMA_READ_LENGTH    = 0x04600008;
static constexpr u32 PI_REG_DMA_WRITE_LENGTH   = 0x0460000C;
static constexpr u32 PI_REG_STATUS             = 0x04600010;
static constexpr u32 PI_REGISTERS_END          = 0x046FFFFF;

static constexpr u32 RI_REGISTERS_BASE         = 0x04700000;
static constexpr u32 RI_REGISTERS_END          = 0x047FFFFF;

static constexpr u32 SI_REGISTERS_BASE         = 0x04800000;
static constexpr u32 SI_REG_DRAM_ADDR          = 0x04800000;
static constexpr u32 SI_REG_PIF_AD_RD64B       = 0x04800004;
static constexpr u32 SI_REG_PIF_AD_WR4B        = 0x04800008;
static constexpr u32 SI_REG_PIF_AD_WR64B       = 0x04800010;
static constexpr u32 SI_REG_PIF_AD_RD4B        = 0x04800014;
static constexpr u32 SI_REG_STATUS             = 0x04800018;
static constexpr u32 SI_REGISTERS_END          = 0x048FFFFF;

static constexpr u32 ISVIEWER_REG_LENGTH       = 0x13FF0014;
static constexpr u32 ISVIEWER_REG_BUFFER_BEGIN = 0x13FF0020;
static constexpr u32 ISVIEWER_REG_BUFFER_END   = 0x13FF0220;

static constexpr u32 PIF_BOOTROM_BASE          = 0x1FC00000;
static constexpr u32 PIF_BOOTROM_END           = 0x1FC007BF;

static constexpr u32 PIF_RAM_BASE              = 0x1FC007C0;
static constexpr u32 PIF_RAM_END               = 0x1FC007FF;

MMU::MMU(N64& system) : m_system(system), m_pi(*this), m_mi(system.vr4300()), m_si(*this) {}

constexpr MMU::AddressRanges MMU::address_range(const u32 virtual_address) {
    if (virtual_address < KSEG0_BASE) {
        return AddressRanges::User;
    }

    if (virtual_address < KSEG1_BASE) {
        return AddressRanges::Kernel0;
    }

    if (virtual_address < KSSEG_BASE) {
        return AddressRanges::Kernel1;
    }

    if (virtual_address < KSEG3_BASE) {
        return AddressRanges::KernelSupervisor;
    }

    return AddressRanges::Kernel3;
}

constexpr u32 MMU::virtual_address_to_physical_address(const u32 virtual_address) {
    const AddressRanges range = address_range(virtual_address);
    switch (range) {
        case AddressRanges::User:
            return virtual_address - KUSEG_BASE;
        case AddressRanges::Kernel0:
            return virtual_address - KSEG0_BASE;
        case AddressRanges::Kernel1:
            return virtual_address - KSEG1_BASE;
        case AddressRanges::KernelSupervisor:
            return virtual_address - KSSEG_BASE;
        case AddressRanges::Kernel3:
            return virtual_address - KSEG3_BASE;
        default:
            UNREACHABLE_MSG("Unreachable address range {}", Common::underlying(range));
    }
}

template <typename T>
T MMU::read(const u32 address) {
    switch (address) {
        case RDRAM_BUILTIN_BASE ... RDRAM_BUILTIN_END:
            if constexpr (Common::TypeIsSame<T, u8>) {
                return m_rdram.at(address - RDRAM_BUILTIN_BASE);
            } else if constexpr (Common::TypeIsSame<T, u16>) {
                const u32 idx = address - RDRAM_BUILTIN_BASE;
                return m_rdram.at(idx + 0) << 8 |
                       m_rdram.at(idx + 1) << 0;
            } else if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - RDRAM_BUILTIN_BASE;
                return m_rdram.at(idx + 0) << 24 |
                       m_rdram.at(idx + 1) << 16 |
                       m_rdram.at(idx + 2) << 8  |
                       m_rdram.at(idx + 3) << 0;
            } else if constexpr (Common::TypeIsSame<T, u64>) {
                const u32 idx = address - RDRAM_BUILTIN_BASE;
                return u64(m_rdram.at(idx + 0)) << 56 |
                       u64(m_rdram.at(idx + 1)) << 48 |
                       u64(m_rdram.at(idx + 2)) << 40 |
                       u64(m_rdram.at(idx + 3)) << 32 |
                       u64(m_rdram.at(idx + 4)) << 24 |
                       u64(m_rdram.at(idx + 5)) << 16 |
                       u64(m_rdram.at(idx + 6)) << 8  |
                       u64(m_rdram.at(idx + 7)) << 0;
            } else {
                UNIMPLEMENTED_MSG("Unrecognized read{} from rdram builtin", Common::TypeSizeInBits<T>);
            }

        case SP_DMEM_BASE ... SP_DMEM_END:
            if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - SP_DMEM_BASE;
                return m_sp_dmem.at(idx + 0) << 24 |
                       m_sp_dmem.at(idx + 1) << 16 |
                       m_sp_dmem.at(idx + 2) << 8  |
                       m_sp_dmem.at(idx + 3) << 0;
            } else {
                UNIMPLEMENTED_MSG("Unrecognized read{} from SP dmem", Common::TypeSizeInBits<T>);
            }

        case SP_IMEM_BASE ... SP_IMEM_END:
            if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - SP_IMEM_BASE;
                return m_sp_imem.at(idx + 0) << 24 |
                       m_sp_imem.at(idx + 1) << 16 |
                       m_sp_imem.at(idx + 2) << 8  |
                       m_sp_imem.at(idx + 3) << 0;
            } else {
                UNIMPLEMENTED_MSG("Unrecognized read{} from SP imem", Common::TypeSizeInBits<T>);
            }

        case MI_REGISTERS_BASE ... MI_REGISTERS_END:
            switch (address) {
                case MI_REG_INTR:
                    return m_mi.interrupt();
                case MI_REG_INTR_MASK:
                    return m_mi.interrupt_mask();

                default:
                    LERROR("Unrecognized read{} from MI register 0x{:08X}", Common::TypeSizeInBits<T>, address);
                    return T(-1);
            }

        case VI_REGISTERS_BASE ... VI_REGISTERS_END:
            switch (address) {
                case VI_REG_V_CURRENT:
                    return m_vi.current_line();

                default:
                    LERROR("Unrecognized read{} from VI register 0x{:08X}", Common::TypeSizeInBits<T>, address);
                    return T(-1);
            }

        case SP_REGISTERS_BASE ... SP_REGISTERS_END:
            switch (address) {
                case 0x04040010: // RSP status
                    return 1;
                case 0x04080000: // RSP program counter
                    return 0;

                default:
                    LERROR("Unrecognized read{} from SP register 0x{:08X}", Common::TypeSizeInBits<T>, address);
                    return T(-1);
            }

        case PI_REGISTERS_BASE ... PI_REGISTERS_END:
            switch (address) {
                case PI_REG_DRAM_ADDRESS:
                    return m_pi.dram_address();
                case PI_REG_DMA_CART_ADDRESS:
                    return m_pi.dma_cart_address();
                case PI_REG_DMA_READ_LENGTH:
                    return 0x7F;
                case PI_REG_DMA_WRITE_LENGTH:
                    return 0x7F;
                case PI_REG_STATUS:
                    return m_pi.status();
                default:
                    LERROR("Unrecognized read{} from PI register 0x{:08X}", Common::TypeSizeInBits<T>, address);
                    return T(-1);
            }

        case SI_REGISTERS_BASE ... SI_REGISTERS_END:
            switch (address) {
                case SI_REG_STATUS:
                    return m_si.status();
                default:
                    LERROR("Unrecognized read{} from SI register 0x{:08X}", Common::TypeSizeInBits<T>, address);
                    return T(-1);
            }

        case 0x10000000 ... 0x1FBFFFFF:
            return m_system.gamepak().read<T>(address - 0x10000000);

        case PIF_RAM_BASE ... PIF_RAM_END:
            if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - PIF_RAM_BASE;
                return m_sp_imem.at(idx + 0) << 24 |
                       m_sp_imem.at(idx + 1) << 16 |
                       m_sp_imem.at(idx + 2) << 8  |
                       m_sp_imem.at(idx + 3) << 0;
            } else {
                UNIMPLEMENTED_MSG("Unrecognized read{} from PIF RAM", Common::TypeSizeInBits<T>);
            }

        case 0x80000000 ... 0xFFFFFFFF:
            return read<T>(virtual_address_to_physical_address(address));

        default:
            LERROR("Unrecognized read{} from 0x{:08X}", Common::TypeSizeInBits<T>, address);
            return T(-1);
    }
}

template <typename T>
void MMU::write(const u32 address, const T value) {
    switch (address) {
        case RDRAM_BUILTIN_BASE ... RDRAM_BUILTIN_END:
            if constexpr (Common::TypeIsSame<T, u8>) {
                m_rdram.at(address - RDRAM_BUILTIN_BASE) = value;
                return;
            } else if constexpr (Common::TypeIsSame<T, u16>) {
                const u32 idx = address - RDRAM_BUILTIN_BASE;
                m_rdram.at(idx + 0) = static_cast<u8>(Common::bit_range<15, 8>(value));
                m_rdram.at(idx + 1) = static_cast<u8>(Common::bit_range<7, 0>(value));
                return;
            } else if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - RDRAM_BUILTIN_BASE;
                m_rdram.at(idx + 0) = static_cast<u8>(Common::bit_range<31, 24>(value));
                m_rdram.at(idx + 1) = static_cast<u8>(Common::bit_range<23, 16>(value));
                m_rdram.at(idx + 2) = static_cast<u8>(Common::bit_range<15, 8>(value));
                m_rdram.at(idx + 3) = static_cast<u8>(Common::bit_range<7, 0>(value));
                return;
            } else if constexpr (Common::TypeIsSame<T, u64>) {
                const u32 idx = address - RDRAM_BUILTIN_BASE;
                m_rdram.at(idx + 0) = static_cast<u8>(Common::bit_range<63, 56>(value));
                m_rdram.at(idx + 1) = static_cast<u8>(Common::bit_range<55, 48>(value));
                m_rdram.at(idx + 2) = static_cast<u8>(Common::bit_range<47, 40>(value));
                m_rdram.at(idx + 3) = static_cast<u8>(Common::bit_range<39, 32>(value));
                m_rdram.at(idx + 4) = static_cast<u8>(Common::bit_range<31, 24>(value));
                m_rdram.at(idx + 5) = static_cast<u8>(Common::bit_range<23, 16>(value));
                m_rdram.at(idx + 6) = static_cast<u8>(Common::bit_range<15, 8>(value));
                m_rdram.at(idx + 7) = static_cast<u8>(Common::bit_range<7, 0>(value));
                return;
            } else {
                UNIMPLEMENTED_MSG("Unimplemented write{} 0x{:08X} to rdram builtin", Common::TypeSizeInBits<T>, value);
            }

        case SP_DMEM_BASE ... SP_DMEM_END:
            if constexpr (Common::TypeIsSame<T, u8>) {
                m_sp_dmem.at(address - SP_DMEM_BASE) = value;
                return;
            } else if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - SP_DMEM_BASE;
                m_sp_dmem.at(idx + 0) = static_cast<u8>(Common::bit_range<31, 24>(value));
                m_sp_dmem.at(idx + 1) = static_cast<u8>(Common::bit_range<23, 16>(value));
                m_sp_dmem.at(idx + 2) = static_cast<u8>(Common::bit_range<15, 8>(value));
                m_sp_dmem.at(idx + 3) = static_cast<u8>(Common::bit_range<7, 0>(value));
                return;
            } else {
                UNIMPLEMENTED_MSG("Unimplemented write{} 0x{:08X} to SP dmem", Common::TypeSizeInBits<T>, value);
            }

        case SP_IMEM_BASE ... SP_IMEM_END:
            if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - SP_IMEM_BASE;
                m_sp_imem.at(idx + 0) = static_cast<u8>(Common::bit_range<31, 24>(value));
                m_sp_imem.at(idx + 1) = static_cast<u8>(Common::bit_range<23, 16>(value));
                m_sp_imem.at(idx + 2) = static_cast<u8>(Common::bit_range<15, 8>(value));
                m_sp_imem.at(idx + 3) = static_cast<u8>(Common::bit_range<7, 0>(value));
                return;
            } else {
                UNIMPLEMENTED_MSG("Unimplemented write{} 0x{:08X} to SP imem", Common::TypeSizeInBits<T>, value);
            }

        case MI_REGISTERS_BASE ... MI_REGISTERS_END:
            switch (address) {
                case MI_REG_MODE:
                    m_mi.set_mode(value);
                    return;
                case MI_REG_INTR_MASK:
                    m_mi.set_interrupt_mask(value);
                    return;
                default:
                    LERROR("Unrecognized write{} 0x{:08X} to MI register 0x{:08X}", Common::TypeSizeInBits<T>, value, address);
                    return;
            }

        case VI_REGISTERS_BASE ... VI_REGISTERS_END:
            switch (address) {
                case VI_REG_CONTROL:
                    m_vi.set_control(static_cast<u32>(value));
                    return;
                case VI_REG_ORIGIN:
                    m_vi.set_origin(static_cast<u32>(value));
                    return;
                case VI_REG_WIDTH:
                    m_vi.set_width(static_cast<u32>(value));
                    return;
                case VI_REG_V_INTR:
                    m_vi.set_interrupt_line(static_cast<u32>(value));
                    return;
                case VI_REG_V_CURRENT:
                    m_mi.cancel_interrupt(MI::InterruptFlags::VI);
                    m_system.vr4300().cop0().set_cause_ip(m_mi.interrupt() & m_mi.interrupt_mask());
                    return;
                case VI_REG_V_START:
                    m_vi.set_vstart(static_cast<u32>(value));
                    return;
                case VI_REG_X_SCALE:
                    m_vi.set_xscale(static_cast<u32>(value));
                    return;
                case VI_REG_Y_SCALE:
                    m_vi.set_yscale(static_cast<u32>(value));
                    return;
                default:
                    LERROR("Unrecognized write{} 0x{:08X} to VI register 0x{:08X}", Common::TypeSizeInBits<T>, value, address);
                    return;
            }

        case PI_REGISTERS_BASE ... PI_REGISTERS_END:
            switch (address) {
                case PI_REG_DRAM_ADDRESS:
                    m_pi.set_dram_address(value & ~0b1);
                    return;
                case PI_REG_DMA_CART_ADDRESS:
                    m_pi.set_dma_cart_address(value & ~0b1);
                    return;
                case PI_REG_DMA_WRITE_LENGTH:
                    m_pi.set_dma_write_length(value);
                    return;
                case PI_REG_STATUS:
                    if (Common::is_bit_enabled<1>(value)) {
                        m_mi.cancel_interrupt(MI::InterruptFlags::PI);
                    }
                    // FIXME: Reset DMA controller and stop any transfer being done if bit 0 is set.
                    return;
                default:
                    LERROR("Unrecognized write{} 0x{:08X} to PI register 0x{:08X}", Common::TypeSizeInBits<T>, value, address);
                    return;
            }

        case SI_REGISTERS_BASE ... SI_REGISTERS_END:
            switch (address) {
                case SI_REG_DRAM_ADDR:
                    m_si.set_dram_address(value);
                    return;
                case SI_REG_PIF_AD_RD64B:
                    m_si.transfer_64_bytes_from_pif_ram(value);
                    return;
                case SI_REG_PIF_AD_WR64B:
                    m_si.transfer_64_bytes_to_pif_ram(value);
                    return;
                case SI_REG_STATUS:
                    m_mi.cancel_interrupt(MI::InterruptFlags::SI);
                    return;
                default:
                    LERROR("Unrecognized write{} 0x{:08X} to SI register 0x{:08X}", Common::TypeSizeInBits<T>, value, address);
                    return;
            }

        case ISVIEWER_REG_LENGTH:
            for (std::size_t i = 0; i < value; i++) {
                std::putchar(m_isviewer_buffer.at(i));
            }
            return;

        case ISVIEWER_REG_BUFFER_BEGIN ... ISVIEWER_REG_BUFFER_END:
            if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - ISVIEWER_REG_BUFFER_BEGIN;
                m_isviewer_buffer.at(idx + 0) = static_cast<u8>(Common::bit_range<31, 24>(value));
                m_isviewer_buffer.at(idx + 1) = static_cast<u8>(Common::bit_range<23, 16>(value));
                m_isviewer_buffer.at(idx + 2) = static_cast<u8>(Common::bit_range<15, 8>(value));
                m_isviewer_buffer.at(idx + 3) = static_cast<u8>(Common::bit_range<7, 0>(value));
                return;
            } else {
                LWARN("unimplemented write{} 0x{:08X} to ISViewer (0x{:08X})", Common::TypeSizeInBits<T>, value, address);
                return;
            }

        case PIF_RAM_BASE ... PIF_RAM_END:
            if constexpr (Common::TypeIsSame<T, u32>) {
                const u32 idx = address - PIF_RAM_BASE;
                m_pif_ram.at(idx + 0) = static_cast<u8>(Common::bit_range<31, 24>(value));
                m_pif_ram.at(idx + 1) = static_cast<u8>(Common::bit_range<23, 16>(value));
                m_pif_ram.at(idx + 2) = static_cast<u8>(Common::bit_range<15, 8>(value));
                m_pif_ram.at(idx + 3) = static_cast<u8>(Common::bit_range<7, 0>(value));
                return;
            } else {
                LWARN("unimplemented write{} 0x{:08X} to PIF RAM (0x{:08X})", Common::TypeSizeInBits<T>, value, address);
                return;
            }

        case 0x80000000 ... 0xFFFFFFFF:
            write<T>(virtual_address_to_physical_address(address), value);
            return;

        default:
            LERROR("Unrecognized write{} 0x{:08X} to 0x{:08X}", Common::TypeSizeInBits<T>, value, address);
            return;
    }
}

u8 MMU::read8(const u32 address) {
    return read<u8>(address);
}

void MMU::write8(const u32 address, const u8 value) {
    write<u8>(address, value);
}

u16 MMU::read16(const u32 address) {
    return read<u16>(address);
}

void MMU::write16(const u32 address, const u16 value) {
    write<u16>(address, value);
}

u32 MMU::read32(const u32 address) {
    return read<u32>(address);
}

void MMU::write32(const u32 address, const u32 value) {
    write<u32>(address, value);
}

u64 MMU::read64(const u32 address) {
    return read<u64>(address);
}

void MMU::write64(const u32 address, const u64 value) {
    write<u64>(address, value);
}
