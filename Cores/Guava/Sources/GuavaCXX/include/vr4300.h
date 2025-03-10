#pragma once

#include <array>
#include <string_view>
#include "common/bits.h"
#include "common/defines.h"
#include "common/types.h"
#include "cop0.h"
#include "cop1.h"

using namespace std::string_view_literals;

class N64;

class VR4300 {
public:
    explicit VR4300(N64& system);

    enum class ExceptionCodes {
        Interrupt = 0,
        TLBModification = 1,
        TLBMissLoad = 2,
        TLBMissStore = 3,
        AddressErrorLoad = 4,
        AddressErrorStore = 5,
        BusErrorInstructionFetch = 6,
        BusErrorLoadStore = 7,
        Syscall = 8,
        Breakpoint = 9,
        ReservedInstruction = 10,
        CoprocessorUnusable = 11,
        ArithmeticOverflow = 12,
        Trap = 13,
        FloatingPoint = 15,
        Watch = 23,
    };

    void throw_exception(ExceptionCodes code);
    template <ExceptionCodes code>
    void throw_address_error_exception(u64 bad_address);

    void step();

    COP0& cop0() { return m_cop0; }
    const COP0& cop0() const { return m_cop0; }

    COP1& cop1() { return m_cop1; }
    const COP1& cop1() const { return m_cop1; }

    u64 pc() const { return m_pc; }

private:
    friend class COP1;

    N64& m_system;
    COP0 m_cop0;
    COP1 m_cop1;

    bool m_enable_trace_logging { false };

    std::array<u64, 32> m_gprs {};
    u64 m_hi { 0 };
    u64 m_lo { 0 };

    static constexpr std::array m_reg_names = {
        "zero"sv,
        "at"sv,
        "v0"sv, "v1"sv,
        "a0"sv, "a1"sv, "a2"sv, "a3"sv,
        "t0"sv, "t1"sv, "t2"sv, "t3"sv, "t4"sv, "t5"sv, "t6"sv, "t7"sv,
        "s0"sv, "s1"sv, "s2"sv, "s3"sv, "s4"sv, "s5"sv, "s6"sv, "s7"sv,
        "t8"sv, "t9"sv,
        "k0"sv, "k1"sv,
        "gp"sv,
        "sp"sv,
        "s8"sv,
        "ra"sv,
    };

    static constexpr std::string_view reg_name(std::size_t reg_id) {
        return m_reg_names.at(reg_id);
    }

    u64 m_pc { 0 };
    u64 m_next_pc { 0 };
    bool m_about_to_branch { false };
    bool m_entering_delay_slot { false };
    bool m_in_delay_slot { false };

    void simulate_pif_routine();

    ALWAYS_INLINE static u8 get_rs(const u32 instruction) {
        return Common::bit_range<25, 21>(instruction);
    }

    ALWAYS_INLINE static u8 get_rt(const u32 instruction) {
        return Common::bit_range<20, 16>(instruction);
    }

    ALWAYS_INLINE static u8 get_rd(const u32 instruction) {
        return Common::bit_range<15, 11>(instruction);
    }

    void decode_and_execute_instruction(u32 instruction);
    void decode_and_execute_special_instruction(u32 instruction);
    void decode_and_execute_regimm_instruction(u32 instruction);
    void decode_and_execute_cop0_instruction(u32 instruction);
    void decode_and_execute_cop1_instruction(u32 instruction);
    void cop2(u32 instruction);

    void add(u32 instruction);
    void addi(u32 instruction);
    void addiu(u32 instruction);
    void addu(u32 instruction);
    void and_(u32 instruction);
    void andi(u32 instruction);
    void beq(u32 instruction);
    void beql(u32 instruction);
    void bgez(u32 instruction);
    void bgezal(u32 instruction);
    void bgezl(u32 instruction);
    void bgtz(u32 instruction);
    void bgtzl(u32 instruction);
    void blez(u32 instruction);
    void bltz(u32 instruction);
    void bltzl(u32 instruction);
    void bne(u32 instruction);
    void bnel(u32 instruction);
    void cache(u32 instruction);
    void cfc1(u32 instruction);
    void ctc1(u32 instruction);
    void dadd(u32 instruction);
    void daddi(u32 instruction);
    void daddiu(u32 instruction);
    void daddu(u32 instruction);
    void ddiv(u32 instruction);
    void ddivu(u32 instruction);
    void div(u32 instruction);
    void divu(u32 instruction);
    void dmfc0(u32 instruction);
    void dmfc1(u32 instruction);
    void dmtc0(u32 instruction);
    void dmtc1(u32 instruction);
    void dmult(u32 instruction);
    void dmultu(u32 instruction);
    void dsll(u32 instruction);
    void dsllv(u32 instruction);
    void dsll32(u32 instruction);
    void dsra(u32 instruction);
    void dsrav(u32 instruction);
    void dsra32(u32 instruction);
    void dsrl(u32 instruction);
    void dsrlv(u32 instruction);
    void dsrl32(u32 instruction);
    void dsub(u32 instruction);
    void dsubu(u32 instruction);
    void eret(u32 instruction);
    void j(u32 instruction);
    void jal(u32 instruction);
    void jalr(u32 instruction);
    void jr(u32 instruction);
    void lb(u32 instruction);
    void lbu(u32 instruction);
    void ld(u32 instruction);
    void ldc1(u32 instruction);
    void ldl(u32 instruction);
    void ldr(u32 instruction);
    void lh(u32 instruction);
    void lhu(u32 instruction);
    void ll(u32 instruction);
    void lui(u32 instruction);
    void lw(u32 instruction);
    void lwc1(u32 instruction);
    void lwl(u32 instruction);
    void lwr(u32 instruction);
    void lwu(u32 instruction);
    void mfc0(u32 instruction);
    void mfc1(u32 instruction);
    void mfhi(u32 instruction);
    void mflo(u32 instruction);
    void mtc0(u32 instruction);
    void mtc1(u32 instruction);
    void mthi(u32 instruction);
    void mtlo(u32 instruction);
    void mult(u32 instruction);
    void multu(u32 instruction);
    void nop(u32 instruction);
    void nor(u32 instruction);
    void or_(u32 instruction);
    void ori(u32 instruction);
    void sb(u32 instruction);
    void sc(u32 instruction);
    void sd(u32 instruction);
    void sdc1(u32 instruction);
    void sdl(u32 instruction);
    void sdr(u32 instruction);
    void sh(u32 instruction);
    void sll(u32 instruction);
    void sllv(u32 instruction);
    void slt(u32 instruction);
    void slti(u32 instruction);
    void sltiu(u32 instruction);
    void sltu(u32 instruction);
    void sra(u32 instruction);
    void srav(u32 instruction);
    void srl(u32 instruction);
    void srlv(u32 instruction);
    void sub(u32 instruction);
    void subu(u32 instruction);
    void sw(u32 instruction);
    void swc1(u32 instruction);
    void swl(u32 instruction);
    void swr(u32 instruction);
    void sync(u32 instruction);
    void teq(u32 instruction);
    void tlbwi(u32 instruction);
    void xor_(u32 instruction);
    void xori(u32 instruction);
};
