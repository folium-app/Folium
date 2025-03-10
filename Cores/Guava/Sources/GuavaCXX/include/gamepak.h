#pragma once

#include <fmt/core.h>
#include <filesystem>
#include <vector>
#include "common/logging.h"
#include "common/defines.h"
#include "common/types.h"

class GamePak {
public:
    explicit GamePak(const std::filesystem::path& path);
    bool swap_bytes_for_endianness();

    template <typename T>
    ALWAYS_INLINE T read(u32 address) const {
        if constexpr (Common::TypeIsSame<T, u8>) {
            return m_rom.at(address);
        } else if constexpr (Common::TypeIsSame<T, u16>) {
            return m_rom.at(address + 0) << 8 |
                   m_rom.at(address + 1) << 0;
        } else if constexpr (Common::TypeIsSame<T, u32>) {
            return m_rom.at(address + 0) << 24 |
                   m_rom.at(address + 1) << 16 |
                   m_rom.at(address + 2) << 8 |
                   m_rom.at(address + 3) << 0;
        } else {
            UNIMPLEMENTED_MSG("Unimplemented read{} from gamepak", Common::TypeSizeInBits<T>);
        }
    }

private:
    std::vector<u8> m_rom {};
};
