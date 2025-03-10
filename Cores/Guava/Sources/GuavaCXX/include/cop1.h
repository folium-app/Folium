#pragma once

#include <array>
#include <string_view>
#include "common/bits.h"
#include "common/defines.h"
#include "common/types.h"

class VR4300;

class COP1 {
public:
    explicit COP1(VR4300& vr4300) : m_vr4300(vr4300) {}

    static std::string reg_name(u32 reg);

    enum class Conditions {
        F,
        UN,
        EQ,
        UEQ,
        OLT,
        ULT,
        OLE,
        ULE,
        SF,
        NGLE,
        SEQ,
        NGL,
        LT,
        NGE,
        LE,
        NGT,
    };
    static std::string_view condition_name(Conditions condition);

    enum Format {
        SingleFloating = 16,
        S = SingleFloating,

        DoubleFloating = 17,
        D = DoubleFloating,

        Word = 20,
        W = Word,

        Long = 21,
        L = Long,
    };
    static char fmt_name(Format fmt);

    union FPR {
        u32 as_u32;
        f32 as_f32;
        u64 as_u64;
        f64 as_f64;
    };

    FPR get_reg(u32 reg) const { return m_fprs[reg]; }
    void set_reg(u32 reg, u64 value) {
        m_fprs[reg].as_u64 = value;
    }

private:
    friend class VR4300;
    VR4300& m_vr4300;

    std::array<u64, 32> m_fgrs {};
    std::array<FPR, 32> m_fprs {};

    union {
        u32 raw {};
        struct {
            u32 revision : 8;
            u32 implementation : 8;
            u32 : 16;
        } flags;
    } m_fcr0;

    union {
        u32 raw { 0x01000800 };
        struct {
            u32 rounding_mode : 2;
            u32 flags : 5;
            u32 enables : 5;
            u32 cause : 6;
            u32 : 5;
            bool condition : 1;
            bool fs : 1;
            u32 : 7;
        } flags;
    } m_fcr31;

    template <Conditions condition, typename T> requires std::is_floating_point_v<T>
    bool meets_condition(T a, T b);

    bool m_condition_signal { false };

    static ALWAYS_INLINE Format get_fmt(const u32 instruction) {
        return static_cast<Format>(Common::bit_range<25, 21>(instruction));
    }

    static ALWAYS_INLINE u8 get_ft(const u32 instruction) {
        return Common::bit_range<20, 16>(instruction);
    }

    static ALWAYS_INLINE u8 get_fs(const u32 instruction) {
        return Common::bit_range<15, 11>(instruction);
    }

    static ALWAYS_INLINE u8 get_fd(const u32 instruction) {
        return Common::bit_range<10, 6>(instruction);
    }

    static ALWAYS_INLINE u8 get_function(const u32 instruction) {
        return Common::bit_range<5, 0>(instruction);
    }

    void add(u32 instruction);
    void bc1f(u32 instruction);
    void bc1fl(u32 instruction);
    void bc1t(u32 instruction);
    void bc1tl(u32 instruction);
    void c(u32 instruction);
    template <Conditions condition>
    void c_impl(u32 instruction);
    void cvt_d(u32 instruction);
    void cvt_s(u32 instruction);
    void div(u32 instruction);
    void mov(u32 instruction);
    void mul(u32 instruction);
    void sub(u32 instruction);
    void trunc_w(u32 instruction);
};
