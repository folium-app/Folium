#include <fmt/core.h>
#include "vr4300.h"
#include "n64.h"

VR4300::VR4300(N64& system) : m_system(system), m_cop1(*this) {
    simulate_pif_routine();
}

void VR4300::simulate_pif_routine() {
    // copied from MAME
    m_gprs[ 1] = 0x0000000000000001;
    m_gprs[ 2] = 0x000000000EBDA536;
    m_gprs[ 3] = 0x000000000EBDA536;
    m_gprs[ 4] = 0x000000000000A536;
    m_gprs[ 5] = 0xFFFFFFFFC0F1D859;
    m_gprs[ 6] = 0xFFFFFFFFA4001F0C;
    m_gprs[ 7] = 0xFFFFFFFFA4001F08;
    m_gprs[ 8] = 0x00000000000000C0;
    m_gprs[ 9] = 0x0000000000000000;
    m_gprs[10] = 0x0000000000000040;
    m_gprs[11] = 0xFFFFFFFFA4000040;
    m_gprs[12] = 0xFFFFFFFFED10D0B3;
    m_gprs[13] = 0x000000001402A4CC;
    m_gprs[14] = 0x000000002DE108EA;
    m_gprs[15] = 0x000000003103E121;
    m_gprs[16] = 0x0000000000000000;
    m_gprs[17] = 0x0000000000000000;
    m_gprs[18] = 0x0000000000000000;
    m_gprs[19] = 0x0000000000000000;
    m_gprs[20] = 0x0000000000000001;
    m_gprs[21] = 0x0000000000000000;
    m_gprs[22] = 0x000000000000003F;
    m_gprs[23] = 0x0000000000000000;
    m_gprs[24] = 0x0000000000000000;
    m_gprs[25] = 0xFFFFFFFF9DEBB54F;
    m_gprs[26] = 0x0000000000000000;
    m_gprs[27] = 0x0000000000000000;
    m_gprs[28] = 0x0000000000000000;
    m_gprs[29] = 0xFFFFFFFFA4001FF0;
    m_gprs[30] = 0x0000000000000000;
    m_gprs[31] = 0xFFFFFFFFA4001550;
    m_hi = 0x000000003FC18657;
    m_lo = 0x000000003103E121;

    m_cop0.set_status(0x34000000);
    m_cop0.set_config(0x7006E463);

    const u32 source_address = 0xB0000000;
    const u32 destination_address = 0xA4000000;
    for (u32 i = 0; i < 0x1000; i++) {
        m_system.mmu().write8(destination_address + i, m_system.mmu().read8(source_address + i));
    }

    m_pc = 0xA4000040;
    m_next_pc = m_pc + 4;
}

// https://n64.readthedocs.io/index.html#exception-handling-process
void VR4300::throw_exception(const ExceptionCodes code) {
    // 1. If the program counter is currently inside a branch delay slot, set the branch delay bit in $Cause (bit 31) to 1. Otherwise, set this bit to 0.
    m_cop0.cause.flags.bd = m_in_delay_slot;

    // 2. If the EXL bit is currently 0, set the $EPC register in COP0 to the current PC. Then, set the EXL bit to 1.
    if (!m_cop0.status.flags.exl) {
        m_cop0.epc = static_cast<s32>(m_pc);
        m_cop0.status.flags.exl = true;

        // A. If we are currently in a branch delay slot, instead set EPC to the address of the branch that we are currently in the delay slot of, i.e. current_pc - 4.
        if (m_in_delay_slot) {
            m_cop0.epc = static_cast<s32>(m_pc - 4);
        }
    }

    // 3. Set the exception code bit in the COP0 $Cause register to the code of the exception that was thrown.
    m_cop0.cause.flags.exc_code = Common::underlying(code);

    // 4. If the coprocessor error is a defined value, i.e. for the coprocessor unusable exception, set the coprocessor error field in $Cause to the coprocessor that caused the error. Otherwise, the value of this field is undefined behavior in hardware, so it shouldn’t matter what you emulate this as.
    // NOTE: This is currently handled in any instructions that would throw a coprocessor unusable exception.
    if (code != ExceptionCodes::CoprocessorUnusable) {
        m_cop0.cause.flags.ce = 0;
    }

    // 5. Jump to the exception vector. A detailed description on how to find the correct exception vector is found on pages 180 through 181 of the manual, and described in less detail below.
    //    A. Note that there is no “delay slot” executed when jumping to the exception vector, execution jumps there immediately.
    // FIXME: Check for the BEV bit.
    switch (code) {
        case ExceptionCodes::TLBMissLoad:
        case ExceptionCodes::TLBMissStore:
        case ExceptionCodes::TLBModification:
            UNIMPLEMENTED();
        case ExceptionCodes::AddressErrorLoad:
        case ExceptionCodes::AddressErrorStore:
        case ExceptionCodes::CoprocessorUnusable:
        case ExceptionCodes::ArithmeticOverflow:
            m_next_pc = 0xFFFFFFFF80000180;
            break;
        case ExceptionCodes::Interrupt:
            m_pc = 0xFFFFFFFF80000180;
            m_next_pc = m_pc + 4;
            break;
        default:
            UNIMPLEMENTED_MSG("Exception code {}", Common::underlying(code));
    }
}

template <VR4300::ExceptionCodes code>
void VR4300::throw_address_error_exception(const u64 bad_address) {
    static_assert(code == ExceptionCodes::AddressErrorLoad || code == ExceptionCodes::AddressErrorStore);

    m_cop0.bad_vaddr = bad_address;
    m_cop0.context.flags.bad_vpn_2 = Common::bit_range<31, 13>(bad_address);
    m_cop0.xcontext.flags.bad_vpn_2 = Common::bit_range<39, 13>(bad_address);
    m_cop0.xcontext.flags.r = Common::bit_range<63, 62>(bad_address);
    throw_exception(code);
}

void VR4300::step() {
    // Always reset the zero register, just in case
    m_gprs[0] = 0;

    const u32 instruction = m_system.mmu().read32(m_pc);
    decode_and_execute_instruction(instruction);

    if (m_in_delay_slot) {
        m_in_delay_slot = false;
    }

    if (m_entering_delay_slot) {
        m_in_delay_slot = true;
        m_entering_delay_slot = false;
    }

    if (!m_about_to_branch) {
        m_pc = m_next_pc;
        m_next_pc += 4;
    } else {
        m_pc += 4;
        m_about_to_branch = false;
    }
}

void VR4300::decode_and_execute_instruction(u32 instruction) {
    const auto op = Common::bit_range<31, 26>(instruction);

    switch (op) {
        case 0b000000:
            decode_and_execute_special_instruction(instruction);
            return;

        case 0b000001:
            decode_and_execute_regimm_instruction(instruction);
            return;

        case 0b010000:
            decode_and_execute_cop0_instruction(instruction);
            return;

        case 0b010001:
            decode_and_execute_cop1_instruction(instruction);
            return;

        case 0b010010:
            cop2(instruction);
            return;

        case 0b000010:
            j(instruction);
            return;

        case 0b000011:
            jal(instruction);
            return;

        case 0b000100:
            beq(instruction);
            return;

        case 0b000101:
            bne(instruction);
            return;

        case 0b000110:
            blez(instruction);
            return;

        case 0b000111:
            bgtz(instruction);
            return;

        case 0b001000:
            addi(instruction);
            return;

        case 0b001001:
            addiu(instruction);
            return;

        case 0b001010:
            slti(instruction);
            return;

        case 0b001011:
            sltiu(instruction);
            return;

        case 0b001100:
            andi(instruction);
            return;

        case 0b001101:
            ori(instruction);
            return;

        case 0b001110:
            xori(instruction);
            return;

        case 0b001111:
            lui(instruction);
            return;

        case 0b010100:
            beql(instruction);
            return;

        case 0b010101:
            bnel(instruction);
            return;

        case 0b010111:
            bgtzl(instruction);
            return;

        case 0b011000:
            daddi(instruction);
            return;

        case 0b011001:
            daddiu(instruction);
            return;

        case 0b011010:
            ldl(instruction);
            return;

        case 0b011011:
            ldr(instruction);
            return;

        case 0b100000:
            lb(instruction);
            return;

        case 0b100001:
            lh(instruction);
            return;

        case 0b100010:
            lwl(instruction);
            return;

        case 0b100011:
            lw(instruction);
            return;

        case 0b100100:
            lbu(instruction);
            return;

        case 0b100101:
            lhu(instruction);
            return;

        case 0b100110:
            lwr(instruction);
            return;

        case 0b100111:
            lwu(instruction);
            return;

        case 0b101000:
            sb(instruction);
            return;

        case 0b101001:
            sh(instruction);
            return;

        case 0b101010:
            swl(instruction);
            return;

        case 0b101011:
            sw(instruction);
            return;

        case 0b101100:
            sdl(instruction);
            return;

        case 0b101101:
            sdr(instruction);
            return;

        case 0b101110:
            swr(instruction);
            return;

        case 0b101111:
            cache(instruction);
            return;

        case 0b110000:
            ll(instruction);
            return;

        case 0b110001:
            lwc1(instruction);
            return;

        case 0b110101:
            ldc1(instruction);
            return;

        case 0b110111:
            ld(instruction);
            return;

        case 0b111000:
            sc(instruction);
            return;

        case 0b111001:
            swc1(instruction);
            return;

        case 0b111101:
            sdc1(instruction);
            return;

        case 0b111111:
            sd(instruction);
            return;

        default:
            UNIMPLEMENTED_MSG("Unrecognized VR4300 op {:06b} ({}, {}) (instr={:08X}, pc={:016X})", op, op >> 3, op & 7, instruction, m_pc);
    }
}

void VR4300::decode_and_execute_special_instruction(u32 instruction) {
    const auto op = Common::bit_range<5, 0>(instruction);

    switch (op) {
        case 0b000000:
            sll(instruction);
            return;

        case 0b000010:
            srl(instruction);
            return;

        case 0b000011:
            sra(instruction);
            return;

        case 0b000100:
            sllv(instruction);
            return;

        case 0b000110:
            srlv(instruction);
            return;

        case 0b000111:
            srav(instruction);
            return;

        case 0b001000:
            jr(instruction);
            return;

        case 0b001001:
            jalr(instruction);
            return;

        case 0b001111:
            sync(instruction);
            return;

        case 0b010000:
            mfhi(instruction);
            return;

        case 0b010001:
            mthi(instruction);
            return;

        case 0b010010:
            mflo(instruction);
            return;

        case 0b010011:
            mtlo(instruction);
            return;

        case 0b010100:
            dsllv(instruction);
            return;

        case 0b010110:
            dsrlv(instruction);
            return;

        case 0b010111:
            dsrav(instruction);
            return;

        case 0b011000:
            mult(instruction);
            return;

        case 0b011001:
            multu(instruction);
            return;

        case 0b011010:
            div(instruction);
            return;

        case 0b011011:
            divu(instruction);
            return;

        case 0b011100:
            dmult(instruction);
            return;

        case 0b011101:
            dmultu(instruction);
            return;

        case 0b011110:
            ddiv(instruction);
            return;

        case 0b011111:
            ddivu(instruction);
            return;

        case 0b100000:
            add(instruction);
            return;

        case 0b100001:
            addu(instruction);
            return;

        case 0b100010:
            sub(instruction);
            return;

        case 0b100011:
            subu(instruction);
            return;

        case 0b100100:
            and_(instruction);
            return;

        case 0b100101:
            or_(instruction);
            return;

        case 0b100110:
            xor_(instruction);
            return;

        case 0b100111:
            nor(instruction);
            return;

        case 0b101010:
            slt(instruction);
            return;

        case 0b101011:
            sltu(instruction);
            return;

        case 0b101100:
            dadd(instruction);
            return;

        case 0b101101:
            daddu(instruction);
            return;

        case 0b101110:
            dsub(instruction);
            return;

        case 0b101111:
            dsubu(instruction);
            return;

        case 0b110100:
            teq(instruction);
            return;

        case 0b111000:
            dsll(instruction);
            return;

        case 0b111010:
            dsrl(instruction);
            return;

        case 0b111011:
            dsra(instruction);
            return;

        case 0b111100:
            dsll32(instruction);
            return;

        case 0b111110:
            dsrl32(instruction);
            return;

        case 0b111111:
            dsra32(instruction);
            return;

        default:
            UNIMPLEMENTED_MSG("unrecognized VR4300 SPECIAL op {:06b} ({}, {}) (instr={:08X}, pc={:016X})", op, op >> 3, op & 7, instruction, m_pc);
    }
}

void VR4300::decode_and_execute_regimm_instruction(u32 instruction) {
    const auto op = Common::bit_range<20, 16>(instruction);

    switch (op) {
        case 0b00000:
            bltz(instruction);
            return;

        case 0b00001:
            bgez(instruction);
            return;

        case 0b00010:
            bltzl(instruction);
            return;

        case 0b00011:
            bgezl(instruction);
            return;

        case 0b10001:
            bgezal(instruction);
            return;

        default:
            UNIMPLEMENTED_MSG("unrecognized VR4300 REGIMM op {:05b} ({}, {}) (instr={:08X}, pc={:016X})", op, op >> 3, op & 7, instruction, m_pc);
    }
}

void VR4300::decode_and_execute_cop0_instruction(u32 instruction) {
    if (Common::is_bit_enabled<25>(instruction)) {
        const auto op = Common::bit_range<5, 0>(instruction);
        switch (op) {
            case 0b000010:
                tlbwi(instruction);
                return;

            case 0b011000:
                eret(instruction);
                return;

            default:
                UNIMPLEMENTED_MSG("unrecognized COP0 CO op {:06b} (instr={:08X}, pc={:016X})", op, instruction, m_pc);
        }
    }

    const auto op = Common::bit_range<25, 21>(instruction);

    switch (op) {
        case 0b00000:
            mfc0(instruction);
            return;

        case 0b00001:
            dmfc0(instruction);
            return;

        case 0b00100:
            mtc0(instruction);
            return;

        case 0b00101:
            dmtc0(instruction);
            return;

        default:
            UNIMPLEMENTED_MSG("unrecognized COP0 op {:05b} (instr={:08X}, pc={:016X})", op, instruction, m_pc);
    }
}

void VR4300::decode_and_execute_cop1_instruction(u32 instruction) {
    if (!Common::is_bit_enabled<25>(instruction)) {
        const auto ct_op = Common::bit_range<25, 21>(instruction);
        switch (ct_op) {
            case 0b00000:
                mfc1(instruction);
                return;

            case 0b00001:
                dmfc1(instruction);
                return;

            case 0b00010:
                cfc1(instruction);
                return;

            case 0b00100:
                mtc1(instruction);
                return;

            case 0b00101:
                dmtc1(instruction);
                return;

            case 0b00110:
                cfc1(instruction);
                return;

            case 0b01000: {
                const auto bc_op = Common::bit_range<20, 16>(instruction);
                switch (bc_op) {
                    case 0b00000:
                        m_cop1.bc1f(instruction);
                        return;
                    case 0b00001:
                        m_cop1.bc1t(instruction);
                        return;
                    case 0b00010:
                        m_cop1.bc1fl(instruction);
                        return;
                    case 0b00011:
                        m_cop1.bc1tl(instruction);
                        return;

                    default:
                        UNIMPLEMENTED_MSG("unrecognized FPU BC op {:05b} (instr={:08X}, pc={:016X})", bc_op, instruction, m_pc);
                }
            }

            default:
                UNIMPLEMENTED_MSG("unrecognized FPU CT op {:05b} (instr={:08X}, pc={:016X})", ct_op, instruction, m_pc);
        }
    }

    const auto op = Common::bit_range<5, 0>(instruction);
    switch (op) {
        case 0b000000:
            m_cop1.add(instruction);
            return;

        case 0b000001:
            m_cop1.sub(instruction);
            return;

        case 0b000010:
            m_cop1.mul(instruction);
            return;

        case 0b000011:
            m_cop1.div(instruction);
            return;

        case 0b000110:
            m_cop1.mov(instruction);
            return;

        case 0b001101:
            m_cop1.trunc_w(instruction);
            return;

        case 0b100000:
            m_cop1.cvt_s(instruction);
            return;

        case 0b100001:
            m_cop1.cvt_d(instruction);
            return;

        case 0b110000 ... 0b111111:
            m_cop1.c(instruction);
            return;

        default:
            UNIMPLEMENTED_MSG("unrecognized FPU op {:06b} (instr={:08X}, pc={:016X})", op, instruction, m_pc);
    }
}

void VR4300::cop2(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("cop2 ${}, ${}", rt, rd);

    m_cop0.cause.flags.ce = 2;
    throw_exception(ExceptionCodes::CoprocessorUnusable);
}

void VR4300::add(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("add ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    s32 result = 0;
    if (__builtin_sadd_overflow(m_gprs[rs], m_gprs[rt], &result)) [[unlikely]] {
        throw_exception(ExceptionCodes::ArithmeticOverflow);
        return;
    }

    m_gprs[rd] = result;
}

void VR4300::addi(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("addi ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    s32 result = 0;
    if (__builtin_sadd_overflow(m_gprs[rs], static_cast<s16>(imm), &result)) [[unlikely]] {
        throw_exception(ExceptionCodes::ArithmeticOverflow);
        return;
    }

    m_gprs[rt] = result;
}

void VR4300::addiu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("addiu ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    m_gprs[rt] = static_cast<s32>(m_gprs[rs] + s16(imm));
}

void VR4300::addu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("addu ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = static_cast<s32>(m_gprs[rs] + m_gprs[rt]);
}

void VR4300::and_(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("and ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = m_gprs[rs] & m_gprs[rt];
}

void VR4300::andi(u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("andi ${}, ${}, 0x{:04X}", reg_name(rs), reg_name(rt), imm);

    m_gprs[rt] = m_gprs[rs] & imm;
}

void VR4300::beq(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("beq ${}, ${}, 0x{:04X}", reg_name(rs), reg_name(rt), new_pc);

    if (m_gprs[rs] == m_gprs[rt]) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
    }

    m_entering_delay_slot = true;
}

void VR4300::beql(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("beql ${}, ${}, 0x{:04X}", reg_name(rs), reg_name(rt), new_pc);

    if (m_gprs[rs] == m_gprs[rt]) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
        m_entering_delay_slot = true;
    } else {
        m_next_pc += 4;
    }
}

void VR4300::bgez(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bgez ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) >= 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
    }

    m_entering_delay_slot = true;
}

void VR4300::bgezal(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bgezal ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) >= 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
    }

    m_entering_delay_slot = true;
    m_gprs[31] = m_pc + 8;
}

void VR4300::bgezl(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bgezl ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) >= 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
        m_entering_delay_slot = true;
    } else {
        m_next_pc += 4;
    }
}

void VR4300::bgtz(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bgtz ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) > 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
    }

    m_entering_delay_slot = true;
}

void VR4300::bgtzl(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bgtzl ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) > 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
        m_entering_delay_slot = true;
    } else {
        m_next_pc += 4;
    }
}

void VR4300::blez(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("blez ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) <= 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
    }

    m_entering_delay_slot = true;
}

void VR4300::bltz(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bltz ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) < 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
    }

    m_entering_delay_slot = true;
}

void VR4300::bltzl(const u32 instruction) {
    const auto rs = get_rs(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bltzl ${}, 0x{:04X}", reg_name(rs), new_pc);

    if (static_cast<s64>(m_gprs[rs]) < 0) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
        m_entering_delay_slot = true;
    } else {
        m_next_pc += 4;
    }
}

void VR4300::bne(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bne ${}, ${}, 0x{:04X}", reg_name(rs), reg_name(rt), new_pc);

    if (m_gprs[rs] != m_gprs[rt]) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
    }

    m_entering_delay_slot = true;
}

void VR4300::bnel(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    [[maybe_unused]] const s16 offset = Common::bit_range<15, 0>(instruction);
    const u64 new_pc = m_pc + 4 + (offset << 2);
    LTRACE_VR4300("bnel ${}, ${}, 0x{:04X}", reg_name(rs), reg_name(rt), new_pc);

    if (m_gprs[rs] != m_gprs[rt]) {
        m_next_pc = new_pc;
        m_about_to_branch = true;
        m_entering_delay_slot = true;
    } else {
        m_next_pc += 4;
    }
}

void VR4300::cache(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto op = Common::bit_range<20, 16>(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("cache {}, 0x{:04X}(${})", op, offset, reg_name(base));

    LWARN("CACHE is stubbed");
}

void VR4300::cfc1(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto fs = m_cop1.get_fs(instruction);
    LTRACE_VR4300("cfc1 ${}, ${}", reg_name(rt), m_cop1.reg_name(fs));

    if (fs == 31) {
        m_gprs[rt] = m_cop1.m_fcr31.raw;
    } else {
        UNIMPLEMENTED();
    }
}

void VR4300::ctc1(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto fs = m_cop1.get_fs(instruction);
    LTRACE_VR4300("ctc1 ${}, ${}", reg_name(rt), m_cop1.reg_name(fs));

    if (fs == 31) {
        m_cop1.m_fcr31.raw = m_gprs[rt];
    } else {
        UNIMPLEMENTED();
    }
}

void VR4300::dadd(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dadd ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    s64 result = 0;
    if (__builtin_saddl_overflow(m_gprs[rs], m_gprs[rt], (long*)&result)) [[unlikely]] {
        throw_exception(ExceptionCodes::ArithmeticOverflow);
        return;
    }

    m_gprs[rd] = result;
}

void VR4300::daddi(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("daddi ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    s64 result = 0;
    if (__builtin_saddl_overflow(m_gprs[rs], static_cast<s16>(imm), (long*)&result)) [[unlikely]] {
        throw_exception(ExceptionCodes::ArithmeticOverflow);
        return;
    }

    m_gprs[rt] = result;
}

void VR4300::daddiu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("daddiu ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    m_gprs[rt] = m_gprs[rs] + s16(imm);
}

void VR4300::daddu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("daddu ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = m_gprs[rs] + m_gprs[rt];
}

void VR4300::ddiv(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("ddiv ${}, ${}", reg_name(rs), reg_name(rt));

    const s64 numerator = m_gprs[rs];
    const s64 denominator = m_gprs[rt];

    if (denominator == 0 && numerator >= 0) {
        m_lo = -1;
        m_hi = numerator;
    } else if (denominator == 0 && numerator < 0) {
        m_lo = 1;
        m_hi = numerator;
    } else if (numerator == std::numeric_limits<s64>::min() && denominator == -1) {
        m_lo = std::numeric_limits<s64>::min();
        m_hi = 0;
    } else [[likely]] {
        m_lo = numerator / denominator;
        m_hi = numerator % denominator;
    }
}

void VR4300::ddivu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("ddivu ${}, ${}", reg_name(rs), reg_name(rt));

    const u64 numerator = m_gprs[rs];
    const u64 denominator = m_gprs[rt];

    if (denominator == 0) {
        m_lo = -1;
        m_hi = numerator;
    } else [[likely]] {
        m_lo = numerator / denominator;
        m_hi = numerator % denominator;
    }
}

void VR4300::div(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("div ${}, ${}", reg_name(rs), reg_name(rt));

    const s32 numerator = m_gprs[rs];
    const s32 denominator = m_gprs[rt];

    if (denominator == 0 && numerator >= 0) {
        m_lo = -1;
        m_hi = numerator;
    } else if (denominator == 0 && numerator < 0) {
        m_lo = 1;
        m_hi = numerator;
    } else if (numerator == std::numeric_limits<s32>::min() && denominator == -1) {
        m_lo = std::numeric_limits<s32>::min();
        m_hi = 0;
    } else [[likely]] {
        m_lo = numerator / denominator;
        m_hi = numerator % denominator;
    }
}

void VR4300::divu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("divu ${}, ${}", reg_name(rs), reg_name(rt));

    const s32 numerator = m_gprs[rs];
    const s32 denominator = m_gprs[rt];

    if (denominator == 0) {
        m_lo = -1;
        m_hi = numerator;
    } else [[likely]] {
        m_lo = numerator / denominator;
        m_hi = numerator % denominator;
    }
}

void VR4300::dmfc0(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dmfc0 ${}, ${}", reg_name(rt), m_cop0.get_reg_name(rd));

    m_gprs[rt] = m_cop0.get_reg(rd);
}

void VR4300::dmfc1(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto fs = m_cop1.get_fs(instruction);
    LTRACE_VR4300("dmfc1 ${}, ${}", reg_name(rt), m_cop1.reg_name(fs));

    m_gprs[rt] = m_cop1.get_reg(fs).as_u64;
}

void VR4300::dmtc0(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dmtc0 ${}, ${}", reg_name(rt), m_cop0.get_reg_name(rd));

    m_cop0.set_reg(rd, m_gprs[rt]);
}

void VR4300::dmtc1(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto fs = m_cop1.get_fs(instruction);
    LTRACE_VR4300("dmtc1 ${}, ${}", reg_name(rt), m_cop1.reg_name(fs));

    m_cop1.set_reg(fs, m_gprs[rt]);
}

void VR4300::dmult(const u32 instruction) {
    // FIXME: edge cases

    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("dmult ${}, ${}", reg_name(rs), reg_name(rt));

    const s128 result = static_cast<s128>(static_cast<s64>(m_gprs[rs])) * static_cast<s128>(static_cast<s64>(m_gprs[rt]));
    m_hi = static_cast<s64>(Common::bit_range<127, 64>(result));
    m_lo = static_cast<s64>(Common::bit_range<63, 0>(result));
}

void VR4300::dmultu(const u32 instruction) {
    // FIXME: edge cases

    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("dmultu ${}, ${}", reg_name(rs), reg_name(rt));

    const u128 result = static_cast<u128>(m_gprs[rs]) * static_cast<u128>(m_gprs[rt]);
    m_hi = static_cast<s64>(Common::bit_range<127, 64>(result));
    m_lo = static_cast<s64>(Common::bit_range<63, 0>(result));
}

void VR4300::dsll(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("dsll ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = m_gprs[rt] << sa;
}

void VR4300::dsllv(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dsllv ${}, ${}, ${}", reg_name(rd), reg_name(rt), reg_name(rs));

    m_gprs[rd] = m_gprs[rt] << Common::lowest_bits(m_gprs[rs], 6);
}

void VR4300::dsll32(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("dsll32 ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = m_gprs[rt] << (32 + sa);
}

void VR4300::dsra(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("dsra ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = static_cast<s64>(m_gprs[rt]) >> sa;
}

void VR4300::dsrav(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dsrav ${}, ${}, ${}", reg_name(rd), reg_name(rt), reg_name(rs));

    m_gprs[rd] = static_cast<s64>(m_gprs[rt]) >> Common::lowest_bits(m_gprs[rs], 6);
}

void VR4300::dsra32(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("dsra32 ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = static_cast<s64>(m_gprs[rt]) >> (32 + sa);
}

void VR4300::dsrl(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("dsrl ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = m_gprs[rt] >> sa;
}

void VR4300::dsrlv(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dsrlv ${}, ${}, ${}", reg_name(rd), reg_name(rt), reg_name(rs));

    m_gprs[rd] = m_gprs[rt] >> Common::lowest_bits(m_gprs[rs], 6);
}

void VR4300::dsrl32(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("dsrl32 ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = m_gprs[rt] >> (32 + sa);
}

void VR4300::dsub(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dsub ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    s64 result = 0;
    if (__builtin_ssubl_overflow(m_gprs[rs], m_gprs[rt], (long*)&result)) [[unlikely]] {
        throw_exception(ExceptionCodes::ArithmeticOverflow);
        return;
    }

    m_gprs[rd] = result;
}

void VR4300::dsubu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("dsubu ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = m_gprs[rs] - m_gprs[rt];
}

void VR4300::eret(const u32 instruction) {
    LTRACE_VR4300("eret");

    if (m_cop0.status.flags.erl) {
        m_next_pc = m_cop0.error_epc;
        m_cop0.status.flags.erl = false;
    } else {
        m_next_pc = m_cop0.epc;
        m_cop0.status.flags.exl = false;
    }
    // FIXME: Clear the LL bit to zero.
}

void VR4300::j(const u32 instruction) {
    const auto target = Common::bit_range<25, 0>(instruction);
    const u32 destination = (m_pc & 0xF0000000) | (target << 2);
    LTRACE_VR4300("j 0x{:08X}", destination);

    if (m_in_delay_slot) [[unlikely]] {
        return;
    }

    m_next_pc = destination;
    m_about_to_branch = true;
    m_entering_delay_slot = true;
}

void VR4300::jal(const u32 instruction) {
    const auto target = Common::bit_range<25, 0>(instruction);
    const u32 destination = (m_pc & 0xF0000000) | (target << 2);
    LTRACE_VR4300("jal 0x{:08X}", destination);

    m_gprs[31] = m_pc + 8;

    m_next_pc = destination;
    m_about_to_branch = true;
    m_entering_delay_slot = true;
}

void VR4300::jalr(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("jalr ${}, ${}", reg_name(rd), reg_name(rs));

    m_next_pc = m_gprs[rs];
    m_gprs[rd] = m_pc + 8;
    m_about_to_branch = true;
    m_entering_delay_slot = true;
}

void VR4300::jr(const u32 instruction) {
    // FIXME: If these low-order two bits are not zero, an address exception will occur when the jump target instruction is fetched.

    const auto rs = get_rs(instruction);
    LTRACE_VR4300("jr ${}", reg_name(rs));

    m_next_pc = m_gprs[rs];
    m_about_to_branch = true;
    m_entering_delay_slot = true;
}

void VR4300::lb(const u32 instruction) {
    // TODO: exceptions

    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const u16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lb ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + static_cast<s16>(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    m_gprs[rt] = static_cast<s8>(m_system.mmu().read8(address));
}

void VR4300::lbu(const u32 instruction) {
    // TODO: exceptions

    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const u16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lbu ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + static_cast<s16>(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    m_gprs[rt] = m_system.mmu().read8(address);
}

void VR4300::ld(const u32 instruction) {
    // FIXME: exceptions

    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("ld ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + s16(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    // Throw an exception if the address is not doubleword-aligned.
    if ((address & 0b111) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorLoad>(address);
        return;
    }

    m_gprs[rt] = m_system.mmu().read64(address);
}

void VR4300::ldc1(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto ft = m_cop1.get_ft(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("ldc1 ${}, 0x{:04X}(${})", m_cop1.reg_name(ft), offset, reg_name(base));

    const u64 doubleword = m_system.mmu().read64(m_gprs[base] + offset);

    if (m_cop0.status.flags.fr) {
        m_cop1.set_reg(ft, doubleword);
    } else {
        ASSERT(ft % 2 == 0);

        u64 value = 0;

        value = Common::highest_bits(m_cop1.get_reg(ft).as_u64, 32);
        value |= Common::lowest_bits(doubleword, 32);
        m_cop1.set_reg(ft, value);

        value = Common::highest_bits(m_cop1.get_reg(ft + 1).as_u64, 32);
        value |= Common::bit_range<63, 32>(doubleword);
        m_cop1.set_reg(ft + 1, value);
    }
}

void VR4300::ldl(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("ldl ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + (offset & ~0x7);
    const u8 bits = (offset & 0x7) * 8;

    u64 value = m_system.mmu().read64(address) << bits;
    value |= Common::lowest_bits(m_gprs[rt], bits);

    m_gprs[rt] = value;
}

void VR4300::ldr(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("ldr ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + (offset & ~0x7);
    const u8 bits = (7 - (offset & 0x7)) * 8;

    u64 value = Common::highest_bits(m_gprs[rt], bits);
    value |= m_system.mmu().read64(address) >> bits;

    m_gprs[rt] = value;
}

void VR4300::lh(const u32 instruction) {
    // TODO: exceptions

    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const u16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lh ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + static_cast<s16>(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    // Throw an exception if the address is not halfword-aligned.
    if ((address & 0b1) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorLoad>(address);
        return;
    }

    m_gprs[rt] = static_cast<s16>(m_system.mmu().read16(address));
}

void VR4300::lhu(const u32 instruction) {
    // TODO: exceptions

    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const u16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lhu ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + static_cast<s16>(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    // Throw an exception if the address is not halfword-aligned.
    if ((address & 0b1) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorLoad>(address);
        return;
    }

    m_gprs[rt] = m_system.mmu().read16(address);
}

void VR4300::ll(const u32 instruction) {
    // FIXME: This is just a copy-paste of LW. This instruction needs to be actually implemented.

    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("ll ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u32 address = m_gprs[base] + s16(offset);
    m_gprs[rt] = static_cast<s32>(m_system.mmu().read32(address));
}

void VR4300::lui(u32 instruction) {
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lui ${}, 0x{:04X}", reg_name(rt), imm);

    m_gprs[rt] = static_cast<s32>(imm << 16);
}

void VR4300::lw(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lw ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + s16(offset);

    // Throw an exception if the address is not sign-extended.
    if ((Common::is_bit_enabled<31>(address) && Common::bit_range<63, 32>(address) != 0xFFFFFFFF) ||
        (!Common::is_bit_enabled<31>(address) && Common::bit_range<63, 32>(address) == 0xFFFFFFFF)) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorLoad>(address);
        return;
    }

    // Throw an exception if the address is not word-aligned.
    if ((address & 0b11) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorLoad>(address);
        return;
    }

    m_gprs[rt] = static_cast<s32>(m_system.mmu().read32(address));
}

void VR4300::lwc1(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto ft = m_cop1.get_ft(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lwc1 ${}, 0x{:04X}(${})", m_cop1.reg_name(ft), offset, reg_name(base));

    const u32 word = m_system.mmu().read32(m_gprs[base] + offset);

    if (m_cop0.status.flags.fr) {
        m_cop1.set_reg(ft, word);
    } else {
        if (ft % 2 == 0) {
            u64 double_bits = Common::highest_bits(m_cop1.get_reg(ft).as_u64, 32);
            double_bits |= word;
            m_cop1.set_reg(ft, double_bits);
        } else {
            u64 double_bits = Common::lowest_bits(m_cop1.get_reg(ft - 1).as_u64, 32);
            double_bits |= (static_cast<u64>(word) << 32);
            m_cop1.set_reg(ft, double_bits);
        }
    }
}

void VR4300::lwl(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lwl ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    // Read from the next word if the offset's low 3 bits are greater than 4
    u64 address = m_gprs[base];
    if ((offset & 0x7) >= 4) {
        address += 4;
    }
    const u8 bits = (offset & 0x7) * 8;

    s32 value = m_system.mmu().read32(address);
    value <<= bits;
    value |= Common::lowest_bits(m_gprs[rt], bits);

    m_gprs[rt] = value;
}

void VR4300::lwr(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lwr ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    // Read from the next word if the offset's low 3 bits are greater than 4
    u64 address = m_gprs[base];
    if ((offset & 0x7) >= 4) {
        address += 4;
    }
    const u8 bits = (7 - (offset & 0x7)) * 8;

    u32 value = m_system.mmu().read32(address);
    value >>= bits;
    value |= Common::highest_bits(m_gprs[rt], bits);

    m_gprs[rt] = static_cast<s32>(value);
}

void VR4300::lwu(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("lwu ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + s16(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    // Throw an exception if the address is not word-aligned.
    if ((address & 0b11) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorLoad>(address);
        return;
    }

    m_gprs[rt] = m_system.mmu().read32(address);
}

void VR4300::mfc0(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("mfc0 ${}, ${}", reg_name(rt), m_cop0.get_reg_name(rd));

    m_gprs[rt] = m_cop0.get_reg(rd);
}

void VR4300::mfc1(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto fs = m_cop1.get_fs(instruction);
    LTRACE_VR4300("mfc1 ${}, ${}", reg_name(rt), m_cop1.reg_name(fs));

    if (m_cop0.status.flags.fr) {
        m_gprs[rt] = m_cop1.get_reg(fs).as_u32;
    } else {
        if (fs % 2 == 0) {
            m_gprs[rt] = Common::bit_range<31, 0>(m_cop1.get_reg(fs).as_u64);
        } else {
            m_gprs[rt] = Common::bit_range<63, 32>(m_cop1.get_reg(fs - 1).as_u64);
        }
    }
}

void VR4300::mfhi(const u32 instruction) {
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("mfhi ${}", reg_name(rd));

    m_gprs[rd] = m_hi;
}

void VR4300::mflo(const u32 instruction) {
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("mflo ${}", reg_name(rd));

    m_gprs[rd] = m_lo;
}

void VR4300::mtc0(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("mtc0 ${}, ${}", reg_name(rt), m_cop0.get_reg_name(rd));

    m_cop0.set_reg(rd, m_gprs[rt]);
}

void VR4300::mtc1(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto fs = m_cop1.get_fs(instruction);
    LTRACE_VR4300("mtc1 ${}, ${}", reg_name(rt), m_cop1.reg_name(fs));

    if (m_cop0.status.flags.fr) {
        u64 double_bits = Common::highest_bits(m_cop1.get_reg(fs).as_u64, 32);
        double_bits |= static_cast<u32>(m_gprs[rt]);
        m_cop1.set_reg(fs, double_bits);
    } else {
        if (fs % 2 == 0) {
            u64 double_bits = Common::highest_bits(m_cop1.get_reg(fs).as_u64, 32);
            double_bits |= static_cast<u32>(m_gprs[rt]);
            m_cop1.set_reg(fs, double_bits);
        } else {
            u64 double_bits = Common::lowest_bits(m_cop1.get_reg(fs).as_u64, 32);
            double_bits |= (m_gprs[rt] << 32);
            m_cop1.set_reg(fs, double_bits);
        }
    }
}

void VR4300::mthi(const u32 instruction) {
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("mthi ${}", reg_name(rd));

    m_hi = m_gprs[rd];
}

void VR4300::mtlo(const u32 instruction) {
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("mtlo ${}", reg_name(rd));

    m_lo = m_gprs[rd];
}

void VR4300::mult(const u32 instruction) {
    // FIXME: edge cases

    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("mult ${}, ${}", reg_name(rs), reg_name(rt));

    const s64 result = m_gprs[rs] * m_gprs[rt];
    m_hi = static_cast<s32>(Common::bit_range<63, 32>(result));
    m_lo = static_cast<s32>(Common::bit_range<31, 0>(result));
}

void VR4300::multu(const u32 instruction) {
    // FIXME: edge cases

    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    LTRACE_VR4300("multu ${}, ${}", reg_name(rs), reg_name(rt));

    const u64 result = m_gprs[rs] * m_gprs[rt];
    m_hi = static_cast<s32>(Common::bit_range<63, 32>(result));
    m_lo = static_cast<s32>(Common::bit_range<31, 0>(result));
}

void VR4300::nop(const u32 instruction) {
    LTRACE_VR4300("nop");
}

void VR4300::nor(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("nor ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = ~(m_gprs[rs] | m_gprs[rt]);
}

void VR4300::or_(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("or ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = m_gprs[rs] | m_gprs[rt];
}

void VR4300::ori(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("ori ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    m_gprs[rt] = m_gprs[rs] | imm;
}

void VR4300::sb(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sb ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + static_cast<s16>(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    m_system.mmu().write8(address, m_gprs[rt]);
}

void VR4300::sc(const u32 instruction) {
    // FIXME: This is just a copy-paste of SW. This instruction needs to be actually implemented.

    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sc ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u32 address = m_gprs[base] + static_cast<s16>(offset);
    m_system.mmu().write32(address, m_gprs[rt]);
}

void VR4300::sd(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sd ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + static_cast<s16>(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    // Throw an exception if the address is not doubleword-aligned.
    if ((address & 0b111) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorStore>(address);
        return;
    }

    m_system.mmu().write64(address, m_gprs[rt]);
}

void VR4300::sdc1(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto ft = m_cop1.get_ft(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sdc1 ${}, 0x{:04X}(${})", m_cop1.reg_name(ft), offset, reg_name(base));

    const u64 address = m_gprs[base] + offset;

    if (m_cop0.status.flags.fr) {
        m_system.mmu().write64(address, m_cop1.get_reg(ft).as_u64);
    } else {
        ASSERT(ft % 2 == 0);

        u64 doubleword = m_cop1.get_reg(ft + 1).as_u32;
        doubleword |= static_cast<u64>(m_cop1.get_reg(ft).as_u32) << 32;
        m_system.mmu().write64(address, doubleword);
    }
}

void VR4300::sdl(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sdl ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + (offset & ~0x7);
    const u8 bits = (offset & 0x7) * 8;

    u64 value = Common::highest_bits(m_system.mmu().read64(address), bits);
    value |= (m_gprs[rt] >> bits);

    m_system.mmu().write64(address, value);
}

void VR4300::sdr(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sdr ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + (offset & ~0x7);
    const u8 bits = (7 - (offset & 0x7)) * 8;

    u64 value = Common::lowest_bits(m_system.mmu().read64(address), bits);
    value |= (m_gprs[rt] << bits);

    m_system.mmu().write64(address, value);
}

void VR4300::sh(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sh ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + static_cast<s16>(offset);

    // FIXME: Do we throw an exception is the address is not sign-extended?

    // Throw an exception if the address is not halfword-aligned.
    if ((address & 0b1) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorStore>(address);
        return;
    }

    m_system.mmu().write16(address, m_gprs[rt]);
}

void VR4300::sll(const u32 instruction) {
    if (instruction == 0) {
        nop(instruction);
        return;
    }

    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("sll ${}, ${}, {}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = static_cast<s32>(m_gprs[rt] << sa);
}

void VR4300::sllv(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("sllv ${}, ${}, {}", reg_name(rd), reg_name(rt), reg_name(rs));

    m_gprs[rd] = static_cast<s32>(m_gprs[rt] << Common::lowest_bits(m_gprs[rs], 5));
}

void VR4300::slt(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("slt ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = (s64(m_gprs[rs]) < s64(m_gprs[rt]));
}

void VR4300::slti(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const s16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("slti ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    m_gprs[rt] = (static_cast<s64>(m_gprs[rs]) < imm);
}

void VR4300::sltiu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const s16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sltiu ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    m_gprs[rt] = (m_gprs[rs] < static_cast<u64>(static_cast<s64>(imm)));
}

void VR4300::sltu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("sltu ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = (m_gprs[rs] < m_gprs[rt]);
}

void VR4300::sra(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("sra ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = static_cast<s32>(m_gprs[rt] >> sa);
}

void VR4300::srav(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("srav ${}, ${}, {}", reg_name(rd), reg_name(rt), reg_name(rs));

    m_gprs[rd] = static_cast<s32>(m_gprs[rt] >> Common::lowest_bits(m_gprs[rs], 5));
}

void VR4300::srl(const u32 instruction) {
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    const auto sa = Common::bit_range<10, 6>(instruction);
    LTRACE_VR4300("srl ${}, ${}, ${}", reg_name(rd), reg_name(rt), sa);

    m_gprs[rd] = static_cast<s32>(static_cast<u32>(m_gprs[rt]) >> sa);
}

void VR4300::srlv(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("srlv ${}, ${}, {}", reg_name(rd), reg_name(rt), reg_name(rs));

    m_gprs[rd] = static_cast<s32>(static_cast<u32>(m_gprs[rt]) >> Common::lowest_bits(m_gprs[rs], 5));
}

void VR4300::sub(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("sub ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    s32 result = 0;
    if (__builtin_ssub_overflow(m_gprs[rs], m_gprs[rt], &result)) [[unlikely]] {
        throw_exception(ExceptionCodes::ArithmeticOverflow);
        return;
    }

    m_gprs[rd] = result;
}

void VR4300::subu(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("subu ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = static_cast<s32>(m_gprs[rs] - m_gprs[rt]);
}

void VR4300::sw(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("sw ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    const u64 address = m_gprs[base] + s16(offset);

    // Throw an exception if the address is not sign-extended.
    if ((Common::is_bit_enabled<31>(address) && Common::bit_range<63, 32>(address) != 0xFFFFFFFF) ||
        (!Common::is_bit_enabled<31>(address) && Common::bit_range<63, 32>(address) == 0xFFFFFFFF)) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorStore>(address);
        return;
    }

    // Throw an exception if the address is not word-aligned.
    if ((address & 0b11) != 0) [[unlikely]] {
        throw_address_error_exception<ExceptionCodes::AddressErrorStore>(address);
        return;
    }

    m_system.mmu().write32(address, m_gprs[rt]);
}

void VR4300::swc1(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto ft = m_cop1.get_ft(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("swc1 ${}, 0x{:04X}(${})", m_cop1.reg_name(ft), offset, reg_name(base));

    const u64 address = m_gprs[base] + offset;

    if (m_cop0.status.flags.fr) {
        m_system.mmu().write32(address, m_cop1.get_reg(ft).as_u32);
    } else {
        if (ft % 2 == 0) {
            m_system.mmu().write32(address, m_cop1.get_reg(ft).as_u32);
        } else {
            m_system.mmu().write32(address, m_cop1.get_reg(ft - 1).as_u32);
        }
    }
}

void VR4300::swl(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("swl ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    // Read from the next word if the offset's low 3 bits are greater than 4
    u64 address = m_gprs[base];
    if ((offset & 0x7) >= 4) {
        address += 4;
    }
    const u8 bits = (offset & 0x3) * 8;

    u32 value = m_gprs[rt];
    value >>= bits;
    value |= Common::highest_bits(m_system.mmu().read32(address), bits);

    m_system.mmu().write32(address, value);
}

void VR4300::swr(const u32 instruction) {
    const auto base = Common::bit_range<25, 21>(instruction);
    const auto rt = get_rt(instruction);
    const s16 offset = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("swr ${}, 0x{:04X}(${})", reg_name(rt), offset, reg_name(base));

    // Read from the next word if the offset's low 3 bits are greater than 4
    u64 address = m_gprs[base];
    if ((offset & 0x7) >= 4) {
        address += 4;
    }
    const u8 bits = (3 - (offset & 0x3)) * 8;

    u32 value = m_gprs[rt];
    value <<= bits;
    value |= Common::lowest_bits(m_system.mmu().read32(address), bits);

    m_system.mmu().write32(address, value);
}

void VR4300::sync(const u32 instruction) {
    // No-op on the VR4300. Defined to maintain compatibility with the VR4400.
    LTRACE_VR4300("sync");
}

void VR4300::teq(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto code = Common::bit_range<15, 6>(instruction);
    LTRACE_VR4300("teq ${}, ${} ({})", reg_name(rs), reg_name(rt), code);

    if (m_gprs[rs] == m_gprs[rt]) {
        throw_exception(ExceptionCodes::Trap);
    }
}

void VR4300::tlbwi(const u32 instruction) {
    LTRACE_VR4300("tlbwi");

    LWARN("TLBWI is stubbed");
}

void VR4300::xor_(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const auto rd = get_rd(instruction);
    LTRACE_VR4300("xor ${}, ${}, ${}", reg_name(rd), reg_name(rs), reg_name(rt));

    m_gprs[rd] = m_gprs[rs] ^ m_gprs[rt];
}

void VR4300::xori(const u32 instruction) {
    const auto rs = get_rs(instruction);
    const auto rt = get_rt(instruction);
    const u16 imm = Common::bit_range<15, 0>(instruction);
    LTRACE_VR4300("xori ${}, ${}, 0x{:04X}", reg_name(rt), reg_name(rs), imm);

    m_gprs[rt] = m_gprs[rs] ^ imm;
}
