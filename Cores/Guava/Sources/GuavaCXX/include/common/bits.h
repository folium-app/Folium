#pragma once

#include <bit>
#include "common/defines.h"
#include "common/types.h"

namespace Common {

template <typename T>
static constexpr ALWAYS_INLINE T lowest_bits(const T number, const u32 number_of_bits) {
    T mask = 0;
    for (u32 i = 0; i < number_of_bits; i++) {
        mask |= (1llu << i);
    }
    return T(number & mask);
}

template <typename T>
static constexpr ALWAYS_INLINE T highest_bits(const T number, const u32 number_of_bits) {
    T mask = 0;
    for (u32 i = TypeSizeInBits<T> - 1; i >= TypeSizeInBits<T> - number_of_bits; i--) {
        mask |= (1llu << i);
    }
    return T(number & mask);
}

template <u8... Bits, typename T>
static constexpr ALWAYS_INLINE void enable_bits(T& number) {
    number |= ((1 << Bits) | ...);
}

template <u8... Bits, typename T>
static constexpr ALWAYS_INLINE void disable_bits(T& number) {
    number &= ~((1 << Bits) | ...);
}

template <u8 Bit, typename T> requires (Bit < TypeSizeInBits<T>)
static constexpr ALWAYS_INLINE bool is_bit_enabled(const T number) {
    return (number & (T(1) << Bit)) != 0;
}

template <u8 UpperBound, u8 LowerBound, typename T>
static consteval T bit_mask_from_range() {
    if (UpperBound < LowerBound) {
        return bit_mask_from_range<LowerBound, UpperBound, T>();
    }

    T mask = 0;
    for (T bit = LowerBound; bit <= UpperBound; bit++) {
        mask |= (T(1) << bit);
    }
    return mask;
}

template <u8 UpperBound, u8 LowerBound, typename T>
static constexpr ALWAYS_INLINE T bit_range(const T value) {
    if (UpperBound < LowerBound) {
        return bit_range<LowerBound, UpperBound, T>(value);
    }

    static_assert(UpperBound < TypeSizeInBits<T>, "Upper bound is higher than T's size");
    static_assert(UpperBound != LowerBound, "Invalid one-bit-wide range. You should use is_bit_enabled instead.");

    const T mask = bit_mask_from_range<UpperBound, LowerBound, T>() >> LowerBound;
    return (value >> LowerBound) & mask;
}

static ALWAYS_INLINE f64 bit_cast_f32_to_f64(const f32 value) {
    const u64 float_bits = static_cast<u64>(std::bit_cast<u32>(value));
    return std::bit_cast<f64>(float_bits);
}

static ALWAYS_INLINE f64 bit_cast_u32_to_f64(const u32 value) {
    return std::bit_cast<f64>(static_cast<u64>(value));
}

static ALWAYS_INLINE f32 bit_cast_f64_to_f32(const f64 f32_as_f64) {
    const u32 double_bits = static_cast<u32>(std::bit_cast<u64>(f32_as_f64));
    return std::bit_cast<f32>(double_bits);
}

}
