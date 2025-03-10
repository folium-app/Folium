#pragma once

#include <array>
#include <filesystem>
#include "common/defines.h"
#include "common/types.h"

static constexpr std::size_t PifSize = 2048;

class PIF {
public:
    explicit PIF(const std::filesystem::path& path);

    ALWAYS_INLINE u32 read(u32 address) const {
        return m_pif.at(address + 0) << 24 |
               m_pif.at(address + 1) << 16 |
               m_pif.at(address + 2) << 8 |
               m_pif.at(address + 3) << 0;
    }

private:
    std::array<u8, PifSize> m_pif {};
};
