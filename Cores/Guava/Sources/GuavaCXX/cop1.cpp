#include "common/logging.h"
#include "cop1.h"
#include "vr4300.h"

std::string COP1::reg_name(const u32 reg) {
    if (reg <= 31) {
        return fmt::format("f{}", reg);
    }

    UNIMPLEMENTED_MSG("unimplemented name for COP1 reg {}", reg);
}

std::string_view COP1::condition_name(COP1::Conditions condition) {
    using namespace std::string_view_literals;
    static constexpr std::array<std::string_view, 16> condition_names = {
        "F"sv, "UN"sv, "EQ"sv, "UEQ"sv, "OLT"sv, "ULT"sv, "OLE"sv, "ULE"sv, "SF"sv, "NGLE"sv, "SEQ"sv, "NGL"sv, "LT"sv, "NGE"sv, "LE"sv, "NGT"sv,
    };
    return condition_names.at(static_cast<std::size_t>(condition));
}

char COP1::fmt_name(const Format fmt) {
    switch (fmt) {
        case Format::SingleFloating:
            return 'S';
        case Format::DoubleFloating:
            return 'D';
        case Format::Word:
            return 'W';
        case Format::Long:
            return 'L';
        default:
            return '?';
    }
}

template <COP1::Conditions condition, typename T> requires std::is_floating_point_v<T>
bool COP1::meets_condition(const T a, const T b) {
    switch (condition) {
        case Conditions::UN:
            return std::isnan(a) || std::isnan(b);
        case Conditions::EQ:
            return a == b;
        case Conditions::OLT:
            return a < b;
        case Conditions::ULT:
            return a < b || (std::isnan(a) || std::isnan(b));
        case Conditions::LT:
            return a < b;
        case Conditions::LE:
            return a <= b;

        case Conditions::F:
        case Conditions::UEQ:
        case Conditions::OLE:
        case Conditions::ULE:
        case Conditions::SF:
        case Conditions::NGLE:
        case Conditions::SEQ:
        case Conditions::NGL:
        case Conditions::NGE:
        case Conditions::NGT:
        default:
            UNIMPLEMENTED_MSG("FPU: Unimplemented condition {}", Common::underlying(condition));
    }
}

void COP1::add(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto ft = get_ft(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("add.{} ${}, ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs), reg_name(ft));

    if (fmt == Format::SingleFloating) {
        m_fprs[fd].as_f32 = m_fprs[fs].as_f32 + m_fprs[ft].as_f32;
    } else if (fmt == Format::DoubleFloating) {
        m_fprs[fd].as_f64 = m_fprs[fs].as_f64 + m_fprs[ft].as_f64;
    } else {
        UNREACHABLE();
    }
}

void COP1::bc1f(const u32 instruction) {
    const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_vr4300.pc() + 4 + (offset << 2);
    LTRACE_FPU("bc1f 0x{:08X}", new_pc);

    if (!m_condition_signal) {
        m_vr4300.m_next_pc = new_pc;
        m_vr4300.m_about_to_branch = true;
    }

    m_vr4300.m_entering_delay_slot = true;
}

void COP1::bc1fl(const u32 instruction) {
    const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_vr4300.pc() + 4 + (offset << 2);
    LTRACE_FPU("bc1fl 0x{:08X}", new_pc);

    if (!m_condition_signal) {
        m_vr4300.m_next_pc = new_pc;
        m_vr4300.m_about_to_branch = true;
        m_vr4300.m_entering_delay_slot = true;
    } else {
        m_vr4300.m_next_pc += 4;
    }
}

void COP1::bc1t(const u32 instruction) {
    const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_vr4300.pc() + 4 + (offset << 2);
    LTRACE_FPU("bc1t 0x{:08X}", new_pc);

    if (m_condition_signal) {
        m_vr4300.m_next_pc = new_pc;
        m_vr4300.m_about_to_branch = true;
    }

    m_vr4300.m_entering_delay_slot = true;
}

void COP1::bc1tl(const u32 instruction) {
    const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_vr4300.pc() + 4 + (offset << 2);
    LTRACE_FPU("bc1tl 0x{:08X}", new_pc);

    if (m_condition_signal) {
        m_vr4300.m_next_pc = new_pc;
        m_vr4300.m_about_to_branch = true;
        m_vr4300.m_entering_delay_slot = true;
    } else {
        m_vr4300.m_next_pc += 4;
    }
}

void COP1::c(const u32 instruction) {
#define COND(x, e) case x: c_impl<Conditions::e>(instruction); return
    const auto condition_bits = Common::bit_range<3, 0>(instruction);
    switch (condition_bits) {
        COND(0b0000, F);
        COND(0b0001, UN);
        COND(0b0010, EQ);
        COND(0b0011, UEQ);
        COND(0b0100, OLT);
        COND(0b0101, ULT);
        COND(0b0110, OLE);
        COND(0b0111, ULE);
        COND(0b1000, SF);
        COND(0b1001, NGLE);
        COND(0b1010, SEQ);
        COND(0b1011, NGL);
        COND(0b1100, LT);
        COND(0b1101, NGE);
        COND(0b1110, LE);
        COND(0b1111, NGT);
        default:
            UNREACHABLE();
    }
}

template <COP1::Conditions condition>
void COP1::c_impl(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto ft = get_ft(instruction);
    const auto fs = get_fs(instruction);
    LTRACE_FPU("c.{}.{} ${}, ${}", condition_name(condition), fmt_name(fmt), reg_name(fs), reg_name(ft));

    if (fmt == Format::SingleFloating) {
        const bool result = meets_condition<condition>(m_fprs[fs].as_f32, m_fprs[ft].as_f32);
        m_fcr31.flags.condition = result;
        m_condition_signal = result;
    } else if (fmt == Format::DoubleFloating) {
        const bool result = meets_condition<condition>(m_fprs[fs].as_f64, m_fprs[ft].as_f64);
        m_fcr31.flags.condition = result;
        m_condition_signal = result;
    } else {
        UNREACHABLE();
    }
}

void COP1::cvt_d(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("cvt.d.{} ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs));

    switch (fmt) {
        case Format::SingleFloating: {
            m_fprs[fd].as_f64 = static_cast<f64>(m_fprs[fs].as_f32);
            break;
        }
        case Format::Word: {
            m_fprs[fd].as_f64 = static_cast<f64>(m_fprs[fs].as_u32);
            break;
        }

        default:
            UNIMPLEMENTED_MSG("cvt.d.{}", fmt_name(fmt));
    }
}

void COP1::cvt_s(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("cvt.s.{} ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs));

    switch (fmt) {
        case Format::DoubleFloating: {
            m_fprs[fd].as_f32 = static_cast<f32>(m_fprs[fs].as_f64);
            break;
        }
        case Format::Word: {
            m_fprs[fd].as_f32 = static_cast<f32>(m_fprs[fs].as_u32);
            break;
        }

        default:
            UNIMPLEMENTED_MSG("cvt.s.{}", fmt_name(fmt));
    }
}

void COP1::div(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto ft = get_ft(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("div.{} ${}, ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs), reg_name(ft));

    if (fmt == Format::SingleFloating) {
        m_fprs[fd].as_f32 = m_fprs[fs].as_f32 / m_fprs[ft].as_f32;
    } else if (fmt == Format::DoubleFloating) {
        m_fprs[fd].as_f64 = m_fprs[fs].as_f64 / m_fprs[ft].as_f64;
    } else {
        UNREACHABLE();
    }
}

void COP1::mov(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("mov.{} ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs));

    m_fprs[fd] = m_fprs[fs];
}

void COP1::mul(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto ft = get_ft(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("mul.{} ${}, ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs), reg_name(ft));

    if (fmt == Format::SingleFloating) {
        m_fprs[fd].as_f32 = m_fprs[fs].as_f32 * m_fprs[ft].as_f32;
    } else if (fmt == Format::DoubleFloating) {
        m_fprs[fd].as_f64 = m_fprs[fs].as_f64 * m_fprs[ft].as_f64;
    } else {
        UNREACHABLE();
    }
}

void COP1::sub(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto ft = get_ft(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("sub.{} ${}, ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs), reg_name(ft));

    if (fmt == Format::SingleFloating) {
        m_fprs[fd].as_f32 = m_fprs[fs].as_f32 - m_fprs[ft].as_f32;
    } else if (fmt == Format::DoubleFloating) {
        m_fprs[fd].as_f64 = m_fprs[fs].as_f64 - m_fprs[ft].as_f64;
    } else {
        UNREACHABLE();
    }
}

void COP1::trunc_w(const u32 instruction) {
    const auto fmt = get_fmt(instruction);
    const auto fs = get_fs(instruction);
    const auto fd = get_fd(instruction);
    LTRACE_FPU("trunc.w.{} ${}, ${}", fmt_name(fmt), reg_name(fd), reg_name(fs));

    if (fmt == Format::SingleFloating) {
        m_fprs[fd].as_u32 = static_cast<u32>(m_fprs[fs].as_f32);
    } else if (fmt == Format::DoubleFloating) {
        m_fprs[fd].as_u32 = static_cast<u32>(m_fprs[fs].as_f64);
    } else {
        UNREACHABLE();
    }
}
