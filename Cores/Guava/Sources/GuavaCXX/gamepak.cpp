#include <bit>
#include <fstream>
#include "common/logging.h"
#include "gamepak.h"

static constexpr u32 Z64_IDENTIFIER = 0x80371240;
static constexpr u32 N64_IDENTIFIER = 0x37804012;

GamePak::GamePak(const std::filesystem::path& path) {
    ASSERT_MSG(std::filesystem::is_regular_file(path), "Provided GamePak is not a regular file: '{}'", path);

    const std::size_t file_size = std::filesystem::file_size(path);
    ASSERT_MSG(file_size >= 0x40, "fatal: Provided GamePak is not big enough: '{}'", path);
    ASSERT_MSG(file_size <= 0xFBFFFFF, "fatal: Provided GamePak is too big: '{}'", path);

    std::ifstream stream(path, std::ios::binary);
    ASSERT_MSG(stream.good(), "Could not open provided GamePak: '{}'", path);

    m_rom.resize(file_size);
    stream.read(reinterpret_cast<char*>(m_rom.data()), m_rom.size());
}

bool GamePak::swap_bytes_for_endianness() {
    const u32 identifier = read<u32>(0);

    if (identifier == Z64_IDENTIFIER) {
        LINFO("Z64 ROM format, no byteswapping required");
        return true;
    }

    if (identifier == N64_IDENTIFIER) {
        LINFO("N64 ROM format, byteswapping...");

        for (std::size_t i = 0; i < m_rom.size(); i += sizeof(u16)) {
            u16* word = reinterpret_cast<u16*>(&m_rom.at(i));
            *word = __builtin_bswap16(*word);
        }

        LINFO("done byteswapping");
        return true;
    }

    LFATAL("Unrecognized ROM format identifier {:08X}", identifier);
    return false;
}
