#pragma once

#include "common/types.h"

class VR4300;

class MI {
public:
    explicit MI(VR4300& vr4300) : m_vr4300(vr4300) {}

    enum class InterruptFlags {
        SP,
        SI,
        AI,
        VI,
        PI,
        DP,
    };

    void cancel_interrupt(const InterruptFlags flags) { m_interrupt &= ~(1 << Common::underlying(flags)); }
    void request_interrupt(const InterruptFlags flags) { m_interrupt |= (1 << Common::underlying(flags)); }

    [[nodiscard]] u32 mode() const { return m_mode.raw; }
    void set_mode(u32 value);

    [[nodiscard]] u32 interrupt() const { return m_interrupt; }
    void set_interrupt(u32 value);

    [[nodiscard]] u32 interrupt_mask() const { return m_interrupt_mask; }
    void set_interrupt_mask(u32 value);

private:
    VR4300& m_vr4300;

    template <std::size_t I>
    void set_interrupt_mask_impl(u32 value);

    union {
        u32 raw {};
        struct {
            u32 init_length : 7;
            bool init_mode : 1;
            bool ebus_test_mode : 1;
            bool rdram_reg_mode : 1;
            u32 : 22;
        } flags;
    } m_mode;

    u32 m_interrupt {};
    u32 m_interrupt_mask {};
};
