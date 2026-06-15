#pragma once
#include <cstdio>
#include <memory>
#include <optional>
#include <unordered_map>
#include <vector>
#include "avocado/disc/disc.h"
#include "avocado/disc/position.h"
#include "avocado/disc/track.h"
#include "avocado/utils/file.h"

namespace disc::format {
struct Ecm : public Disc {
   private:
    std::string file;
    std::vector<uint8_t> data;

   public:
    Ecm(std::string file, std::vector<uint8_t> data);

    std::string getFile() const override;
    Position getDiskSize() const override;
    size_t getTrackCount() const override;
    Position getTrackBegin(int track) const override;
    Position getTrackStart(int track) const override;
    Position getTrackLength(int track) const override;
    int getTrackByPosition(Position pos) const override;

    disc::Sector read(Position pos) override;
};
}  // namespace disc::format
