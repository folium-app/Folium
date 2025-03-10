#pragma once

#include <array>
#include <string_view>
#include "common/bits.h"
#include "common/types.h"

class COP0 {
public:
    static std::string_view get_reg_name(u8 reg);

    template <u8 InterruptBit>
    void enable_cause_ip_bit() {
        cause.flags.ip |= (1 << InterruptBit);
    }

    template <u8 InterruptBit>
    void disable_cause_ip_bit() {
        cause.flags.ip &= ~(1 << InterruptBit);
    }

    void set_cause_ip(u32 value) { cause.flags.ip = value; }

    [[nodiscard]] bool should_service_interrupt() const;

    [[nodiscard]] u64 get_reg(u8 reg) const;

    void increment_cycle_count(u32 cycles);

private:
    friend class VR4300;

    void set_reg(u8 reg, u64 value);

    u32 index {};
    void set_index(u32 index);

    u32 random {};
    u64 entry_lo0 {};
    u64 entry_lo1 {};

    union {
        u64 raw {};
        struct {
            u64 : 4;
            u64 bad_vpn_2 : 19;
            u64 pte_base : 41;
        } flags;
    } context {};
    void set_context(u64 raw);

    u32 page_mask {};
    u32 wired {};
    u64 bad_vaddr { -1lu };
    u32 count {};
    u64 entry_hi {};
    u32 compare {};

    union {
        u32 raw;
        struct {
            bool ie : 1;
            bool exl : 1;
            bool erl : 1;
            u32 ksu : 2;
            bool ux : 1;
            bool sx : 1;
            bool kx : 1;
            u32 im : 8;
            u32 ds : 9;
            bool re : 1;
            bool fr : 1;
            bool rp : 1;
            bool cu0 : 1;
            bool cu1 : 1;
            u32 : 2; // coprocessors 2 and 3 enabled, which are ignored by the N64
        } flags;
    } status {};
    void set_status(u32 raw);

    union {
        u32 raw { 0xB000007C };
        struct {
            u32 : 2;
            u32 exc_code : 5;
            u32 : 1;
            u32 ip : 8;
            u32 : 12;
            u32 ce : 2;
            u32 : 1;
            bool bd : 1;
        } flags;
    } cause;
    void set_cause(u32 raw);

    u64 epc {};

    u32 config {};
    void set_config(u32 raw);

    u32 ll_addr {};
    u32 watch_lo {};
    u32 watch_hi {};

    union {
        u64 raw {};
        struct {
            u64 : 4;
            u64 bad_vpn_2 : 27;
            u64 r : 2;
            u64 pte_base : 31;
        } flags;
    } xcontext {};
    void set_xcontext(u64 raw);

    u32 parity_error {};
    u32 cache_error {};
    u32 tag_lo {};
    u32 tag_hi {};
    u64 error_epc {};
};
