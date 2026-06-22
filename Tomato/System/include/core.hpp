/*
 * Copyright (C) 2025 fleroviux
 *
 * Licensed under GPLv3 or any later version.
 * Refer to the included LICENSE file.
 */

#include "nba/core_base.hpp"
#include "nba/scheduler.hpp"
#include "nba/arm/arm7tdmi.hpp"
#include "nba/bus/bus.hpp"
#include "nba/hw/apu/apu.hpp"
#include "nba/hw/ppu/ppu.hpp"
#include "nba/hw/dma/dma.hpp"
#include "nba/hw/irq/irq.hpp"
#include "nba/hw/keypad/keypad.hpp"
#include "nba/hw/timer/timer.hpp"

namespace nba::core {

struct Core final : CoreBase {
  Core(std::shared_ptr<Config> config);

  void Reset() override;

  void Attach(std::vector<u8> const& bios) override;
  void Attach(ROM&& rom) override;
  auto CreateRTC() -> std::unique_ptr<RTC> override;
  auto CreateSolarSensor() -> std::unique_ptr<SolarSensor> override;
  void LoadState(SaveState const& state) override;
  void CopyState(SaveState& state) override;
  void SetKeyStatus(Key key, bool pressed) override;
  void Run(int cycles) override;

  auto GetROM() -> ROM& override;
  auto GetPRAM() -> u8* override;
  auto GetVRAM() -> u8* override;
  auto GetOAM() -> u8* override;
  auto PeekByteIO(u32 address) -> u8  override;
  auto PeekHalfIO(u32 address) -> u16 override;
  auto PeekWordIO(u32 address) -> u32 override;
  auto GetBGHOFS(int id) -> u16 override;
  auto GetBGVOFS(int id) -> u16 override;

  Scheduler& GetScheduler() override;

private:
  void SkipBootScreen();
  auto SearchSoundMainRAM() -> u32;

  u32 hle_audio_hook;
  std::shared_ptr<Config> config;

  Scheduler scheduler;

  arm::ARM7TDMI cpu;
  IRQ irq;
  DMA dma;
  APU apu;
  PPU ppu;
  Timer timer;
  KeyPad keypad;
  Bus bus;
};

} // namespace nba::core
