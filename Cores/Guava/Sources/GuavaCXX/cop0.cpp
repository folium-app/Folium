#include "common/logging.h"
#include "cop0.h"

std::string_view COP0::get_reg_name(const u8 reg) {
    using namespace std::string_view_literals;

    static constexpr std::array<std::string_view, 32> reg_names = {
        "Index"sv,
        "Random"sv,
        "EntryLo0"sv,
        "EntryLo1"sv,
        "Context"sv,
        "PageMask"sv,
        "Wired"sv,
        "7"sv,
        "BadVAddr"sv,
        "Count"sv,
        "EntryHi"sv,
        "Compare"sv,
        "Status"sv,
        "Cause"sv,
        "EPC"sv,
        "PRId"sv,
        "Config"sv,
        "LLAddr"sv,
        "WatchLo"sv,
        "WatchHi"sv,
        "XContext"sv,
        "21"sv,
        "22"sv,
        "23"sv,
        "24"sv,
        "25"sv,
        "ParityError"sv,
        "CacheError"sv,
        "TagLo"sv,
        "TagHi"sv,
        "ErrorEPC"sv,
        "31"sv,
    };

    return reg_names.at(reg);
}

bool COP0::should_service_interrupt() const {
    const bool interrupts_pending = (status.flags.im & cause.flags.ip) != 0;
    const bool interrupts_enabled = status.flags.ie;
    const bool handling_exception = status.flags.exl;
    const bool handling_error = status.flags.erl;

    return (interrupts_pending && interrupts_enabled && !handling_exception && !handling_error);
}

u64 COP0::get_reg(const u8 reg) const {
    switch (reg) {
        case 0:
            return index;
        case 1:
            return random;
        case 2:
            return entry_lo0;
        case 3:
            return entry_lo1;
        case 4:
            return context.raw;
        case 6:
            return wired;
        case 8:
            return bad_vaddr;
        case 9:
            return count;
        case 10:
            return entry_hi;
        case 11:
            return compare;
        case 12:
            return status.raw;
        case 13:
            return cause.raw;
        case 14:
            return epc;
        case 15: // PRId
            return (0 << 16) | (0x0B << 8) | (0x22 << 0);
        case 16:
            return config;
        case 17:
            return ll_addr;
        case 20:
            return xcontext.raw;
        case 30:
            return error_epc;
        default:
            UNIMPLEMENTED_MSG("unimplemented get COP0 reg {}", reg);
            return -1;
    }
}

void COP0::set_reg(const u8 reg, const u64 value) {
    switch (reg) {
        case 0:
            set_index(static_cast<u32>(value));
            return;
        case 1:
            random = static_cast<u32>(value);
            return;
        case 2:
            entry_lo0 = value;
            return;
        case 3:
            entry_lo1 = value;
            return;
        case 4:
            set_context(value);
            return;
        case 5:
            page_mask = static_cast<u32>(value);
            return;
        case 6:
            wired = Common::lowest_bits(static_cast<u32>(value), 6);
            return;
        case 8:
            // BadVaddr is read only - ignore
            return;
        case 9:
            count = static_cast<u32>(value);
            return;
        case 10:
            entry_hi = static_cast<u32>(value);
            return;
        case 11:
            compare = static_cast<u32>(value);
            disable_cause_ip_bit<7>();
            return;
        case 12:
            set_status(static_cast<u32>(value));
            return;
        case 13:
            set_cause(static_cast<u32>(value));
            return;
        case 14:
            epc = value;
            return;
        case 15:
            // PRId - readonly
            return;
        case 16:
            set_config(value);
            return;
        case 17:
            ll_addr = static_cast<u32>(value);
            return;
        case 18:
            watch_lo = value;
            return;
        case 20:
            set_xcontext(value);
            return;
        case 28:
            tag_lo = static_cast<u32>(value);
            return;
        case 29:
            tag_hi = static_cast<u32>(value);
            return;
        case 30:
            error_epc = value;
            return;
        default:
            UNIMPLEMENTED_MSG("unimplemented set COP0 reg {}", reg);
    }
}

void COP0::set_index(const u32 index_) {
    index = index_;

    index &= ~Common::bit_mask_from_range<30, 6, u32>();
}

void COP0::set_context(const u64 raw) {
    context.raw = raw;

    context.raw &= ~Common::bit_mask_from_range<3, 0, u64>();
}

void COP0::set_status(const u32 raw) {
    status.raw = raw;

    Common::disable_bits<19>(status.raw);
}

void COP0::set_cause(const u32 raw) {
    cause.raw = raw;

    Common::disable_bits<0, 1, 7, 30>(cause.raw);
    cause.raw &= ~Common::bit_mask_from_range<16, 27, u32>();
}

void COP0::set_config(const u32 raw) {
    config = raw;

    Common::disable_bits<31>(config);
    config &= ~Common::bit_mask_from_range<23, 16, u32>();
    config |= (0b00000110 << 16);
    config &= ~Common::bit_mask_from_range<14, 4, u32>();
    config |= (0b11001000110 << 4);
}

void COP0::set_xcontext(const u64 raw) {
    xcontext.raw = raw;

    xcontext.raw &= ~Common::bit_mask_from_range<3, 0, u64>();
}

void COP0::increment_cycle_count(u32 cycles) {
    for (; cycles > 0; cycles--) {
        count++;
        if (count == compare) {
            enable_cause_ip_bit<7>();
        }
    }
}
