#include <utility>
#include "common/bits.h"
#include "mi.h"
#include "vr4300.h"

void MI::set_mode(const u32 value) {
    m_mode.flags.init_length = Common::bit_range<0, 6>(value);

    if (Common::is_bit_enabled<7>(value)) {
        m_mode.flags.init_mode = false;
    }

    if (Common::is_bit_enabled<8>(value)) {
        m_mode.flags.init_mode = true;
    }

    if (Common::is_bit_enabled<9>(value)) {
        m_mode.flags.ebus_test_mode = false;
    }

    if (Common::is_bit_enabled<10>(value)) {
        m_mode.flags.ebus_test_mode = true;
    }

    if (Common::is_bit_enabled<11>(value)) {
        cancel_interrupt(InterruptFlags::DP);
    }

    if (Common::is_bit_enabled<12>(value)) {
        m_mode.flags.rdram_reg_mode = false;
    }

    if (Common::is_bit_enabled<13>(value)) {
        m_mode.flags.rdram_reg_mode = true;
    }
}

template <std::size_t I>
void MI::set_interrupt_mask_impl(const u32 value) {
    if (!Common::is_bit_enabled<I>(value)) {
        return;
    }

    if constexpr (I % 2 == 0) {
        Common::disable_bits<I / 2>(m_interrupt_mask);
        if constexpr (I == 6) {
            m_vr4300.cop0().disable_cause_ip_bit<2>();
        }
    } else {
        Common::enable_bits<I / 2>(m_interrupt_mask);
    }
}

void MI::set_interrupt_mask(const u32 value) {
    // From n64brew:
    //     READ:                             WRITE:
    //     [11]   —                          [11]   Set DP Interrupt Mask
    //     [10]   —                          [10]   Clear DP Interrupt Mask
    //     [9]    —                          [9]    Set PI Interrupt Mask
    //     [8]    —                          [8]    Clear PI Interrupt Mask
    //     [7]    —                          [7]    Set VI Interrupt Mask
    //     [6]    —                          [6]    Clear VI Interrupt Mask
    //     [5]    DP Interrupt Mask          [5]    Set AI Interrupt Mask
    //     [4]    PI Interrupt Mask          [4]    Clear AI Interrupt Mask
    //     [3]    VI Interrupt Mask          [3]    Set SI Interrupt Mask
    //     [2]    AI Interrupt Mask          [2]    Clear SI Interrupt Mask
    //     [1]    SI Interrupt Mask          [1]    Set SP Interrupt Mask
    //     [0]    SP Interrupt Mask          [0]    Clear SP Interrupt Mask

    static constexpr int Iterations = 12;

    [this, value]<std::size_t... I>(std::index_sequence<I...>) {
        (set_interrupt_mask_impl<I>(value), ...);
    }(std::make_index_sequence<Iterations>{});
}
