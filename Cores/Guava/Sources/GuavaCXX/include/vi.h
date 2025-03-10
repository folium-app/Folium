#pragma once

#include "common/types.h"

class VI {
public:
    VI() = default;

    void bump_current_line();

    [[nodiscard]] u32 control() const { return m_control; }
    void set_control(const u32 value) { m_control = value; }

    [[nodiscard]] u32 origin() const { return m_origin; }
    void set_origin(const u32 value) { m_origin = value; }

    [[nodiscard]] u32 width() const { return m_width; }
    void set_width(const u32 value) { m_width = value; }

    [[nodiscard]] u32 interrupt_line() const { return m_interrupt_line; }
    void set_interrupt_line(const u32 value) { m_interrupt_line = value; }

    [[nodiscard]] u32 current_line() const { return m_current_line; }

    [[nodiscard]] u32 vstart() const { return m_vstart; }
    void set_vstart(const u32 value) { m_vstart = value; }

    [[nodiscard]] u32 xscale() const { return m_xscale; }
    void set_xscale(const u32 value) { m_xscale = value; }

    [[nodiscard]] u32 yscale() const { return m_yscale; }
    void set_yscale(const u32 value) { m_yscale = value; }

private:
    u32 m_control {};
    u32 m_origin {};
    u32 m_width {};
    u32 m_interrupt_line { 0x3FF };
    u32 m_current_line {};
    u32 m_burst {};
    u32 m_vsync {};
    u32 m_hsync {};
    u32 m_leap {};
    u32 m_hstart {};
    u32 m_vstart {};
    u32 m_vburst {};
    u32 m_xscale {};
    u32 m_yscale {};
};
