#pragma once

#include "gamepak.h"
#include "mmu.h"
#include "pif.h"
#include "vr4300.h"

#include <span>
#include <string_view>

extern void render_screen(const N64& n64);
extern void handle_frontend_events();

class N64 {
public:
    N64(PIF& pif, GamePak& gamepak) : m_pif(pif), m_gamepak(gamepak), m_mmu(*this), m_vr4300(*this) {}

    void run();

    PIF& pif() { return m_pif; }
    const PIF& pif() const { return m_pif; }
    GamePak& gamepak() { return m_gamepak; }
    const GamePak& gamepak() const { return m_gamepak; }
    MMU& mmu() { return m_mmu; }
    const MMU& mmu() const { return m_mmu; }
    VR4300& vr4300() { return m_vr4300; }
    const VR4300& vr4300() const { return m_vr4300; }

private:
    PIF& m_pif;
    GamePak& m_gamepak;
    MMU m_mmu;
    VR4300 m_vr4300;

    u32 m_scanline_cycles {};
    u32 m_frame_cycles {};
};
