#pragma once

#include <source_location>
#include <fmt/color.h>
#include <fmt/core.h>
#include <fmt/std.h>

#define LTRACE_VR4300(disasm_fmt, ...) if (m_enable_trace_logging) fmt::print("trace: {:016X}: {:08X}  " disasm_fmt "\n", u64(s32(m_pc)), instruction, ##__VA_ARGS__)
#define LTRACE_FPU(disasm_fmt, ...) fmt::print("trace: {:016X}: {:08X}  " disasm_fmt "\n", u64(s32(m_vr4300.pc())), instruction, ##__VA_ARGS__)

#define LINFO(format, ...) fmt::print(fmt::emphasis::bold | fg(fmt::color::white), "info: " format "\x1b[0m\n", ##__VA_ARGS__)
#define LWARN(format, ...) fmt::print(fmt::emphasis::bold | fg(fmt::color::yellow), "warning: " format "\x1b[0m\n", ##__VA_ARGS__)
#define LERROR(format, ...) fmt::print(fmt::emphasis::bold | fg(fmt::color::red), "error: " format "\x1b[0m\n", ##__VA_ARGS__)
#define LFATAL(format, ...) fmt::print(fmt::emphasis::bold | fg(fmt::color::fuchsia), "fatal: " format "\x1b[0m\n", ##__VA_ARGS__)

#define ASSERT(condition) \
    do { \
        if (!(condition)) { \
            [[maybe_unused]] constexpr std::source_location sl = std::source_location::current(); \
            LFATAL("Assertion failed at {}:{} ({})", sl.file_name(), sl.line(), sl.function_name()); \
            LFATAL("{}", #condition); \
            std::terminate(); \
        } \
    } while (false)

#define ASSERT_MSG(condition, format, ...) \
    do { \
        if (!(condition)) { \
            [[maybe_unused]] constexpr std::source_location sl = std::source_location::current(); \
            LFATAL("Assertion failed at {}:{} ({})", sl.file_name(), sl.line(), sl.function_name()); \
            LFATAL(format, ##__VA_ARGS__); \
            std::terminate(); \
        } \
    } while (false)

#define UNREACHABLE() \
    do { \
        [[maybe_unused]] constexpr std::source_location sl = std::source_location::current(); \
        LFATAL("Unreachable code at {}:{} ({})", sl.file_name(), sl.line(), sl.function_name()); \
        std::terminate(); \
    } while (false)

#define UNREACHABLE_MSG(format, ...) \
    do { \
        [[maybe_unused]] constexpr std::source_location sl = std::source_location::current(); \
        LFATAL("Unreachable code at {}:{} ({})", sl.file_name(), sl.line(), sl.function_name()); \
        LFATAL(format, ##__VA_ARGS__); \
        std::terminate(); \
    } while (false)

#define UNIMPLEMENTED() \
    do { \
        [[maybe_unused]] constexpr std::source_location sl = std::source_location::current(); \
        LFATAL("Unimplemented code at {}:{} ({})", sl.file_name(), sl.line(), sl.function_name()); \
        std::terminate(); \
    } while (false)

#define UNIMPLEMENTED_MSG(format, ...) \
    do { \
        [[maybe_unused]] constexpr std::source_location sl = std::source_location::current(); \
        LFATAL("Unimplemented code at {}:{} ({})", sl.file_name(), sl.line(), sl.function_name()); \
        LFATAL(format, ##__VA_ARGS__); \
        std::terminate(); \
    } while (false)
