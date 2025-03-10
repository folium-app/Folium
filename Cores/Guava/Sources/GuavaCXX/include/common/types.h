#pragma once

#include <cstdint>
#include <type_traits>

using u8 = std::uint8_t;
using u16 = std::uint16_t;
using u32 = std::uint32_t;
using u64 = std::uint64_t;
using s8 = std::int8_t;
using s16 = std::int16_t;
using s32 = std::int32_t;
using s64 = std::int64_t;

#ifdef __SIZEOF_INT128__
using u128 = __uint128_t;
using s128 = __int128_t;
#else
#error "No 128-bit types"
#endif

using f32 = float;
using f64 = double;

namespace Common {

template <typename T>
static constexpr std::size_t TypeSizeInBits = sizeof(T) * 8;

template <typename T1, typename T2>
static constexpr bool TypeIsSame = std::is_same_v<T1, T2>;

template <typename Enum>
static constexpr auto underlying(Enum e) {
    return static_cast<std::underlying_type_t<Enum>>(e);
}

}
