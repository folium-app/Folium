#include "n64.h"

static constexpr u32 CyclesPerSecond = 93'750'000;
static constexpr u32 CyclesPerFrame = CyclesPerSecond / 60;
static constexpr u32 CyclesPerHalfline = CyclesPerFrame / 512 / 2;

void N64::run() {
    if (m_vr4300.cop0().should_service_interrupt()) {
        m_vr4300.throw_exception(VR4300::ExceptionCodes::Interrupt);
    }

    m_vr4300.step();

    // FIXME: Get the number of cycles spent from VR4300
    static constexpr u32 CyclesStub = 3;
    m_scanline_cycles += CyclesStub;
    m_frame_cycles += CyclesStub;
    m_vr4300.cop0().increment_cycle_count(CyclesStub);

    if (m_scanline_cycles >= CyclesPerHalfline) {
        m_scanline_cycles -= CyclesPerHalfline;
        m_mmu.vi().bump_current_line();
    }

    if (const auto& mi = m_mmu.mi(); (mi.interrupt() & mi.interrupt_mask()) != 0) {
        m_vr4300.cop0().enable_cause_ip_bit<2>();
    }

    if (const auto& vi = m_mmu.vi(); vi.current_line() == vi.interrupt_line()) {
        m_mmu.mi().request_interrupt(MI::InterruptFlags::VI);
    }

    if (m_frame_cycles >= CyclesPerFrame) {
        m_frame_cycles -= CyclesPerFrame;
        render_screen(*this);
        handle_frontend_events();
    }
}
