#include <fstream>
#include "common/logging.h"
#include "pif.h"

PIF::PIF(const std::filesystem::path& path) {
    ASSERT_MSG(std::filesystem::is_regular_file(path), "Provided PIF is not a regular file: '{}'", path);
    ASSERT_MSG(std::filesystem::file_size(path) == PifSize, "Provided PIF is not {} bytes: '{}'", PifSize, path);

    std::ifstream stream(path, std::ios::binary);
    ASSERT_MSG(stream.good(), "Could not open provided PIF: '{}'", path);

    stream.read(reinterpret_cast<char*>(m_pif.data()), PifSize);
}
