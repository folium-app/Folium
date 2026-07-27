#pragma once
#include "avocado/constants.h"
#include "avocado/cpu/cpu.h"
#include "avocado/device/cache_control.h"
#include "avocado/device/cdrom/cdrom.h"
#include "avocado/device/controller/controller.h"
#include "avocado/device/dma/dma.h"
#include "avocado/device/expansion2.h"
#include "avocado/device/gpu/gpu.h"
#include "avocado/device/interrupt.h"
#include "avocado/device/mdec/mdec.h"
#include "avocado/device/memory_control.h"
#include "avocado/device/ram_control.h"
#include "avocado/device/serial.h"
#include "avocado/device/spu/spu.h"
#include "avocado/device/timer.h"
#include "avocado/utils/macros.h"
#include "avocado/utils/timing.h"

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <ranges>
#include <vector>

/**
 * NOTE:
 * Build flags are configured with Premake5 build system
 */

/**
 * #define ENABLE_IO_LOG
 * Switch --enable-io-log
 * Default: false
 *
 * Enables IO access buffer log
 */

/**
 * #define ENABLE_BIOS_HOOKS
 * Switch --enable-bios-hooks
 * Default: false
 *
 * Enables BIOS syscall hooking/logging
 */

namespace bios {
struct Function;
}

struct System {
    enum class State {
        halted,  // reset to run again
        stop,    // after reset
        pause,   // if debugger is attached
        run      // normal state
    } state{State::stop};
    
    std::vector<uint8_t> bios, ram, expansion_region_1, scratchpad;

    bool debugOutput = true;  // Print BIOS logs
    bool biosLoaded = false;

    uint64_t cycles;

    // Devices
    std::unique_ptr<mips::CPU> cpu;

    std::unique_ptr<CacheControl> cacheControl;
    std::unique_ptr<device::cdrom::CDROM> cdrom;
    std::unique_ptr<device::controller::Controller> controller;
    std::unique_ptr<device::dma::DMA> dma;
    std::unique_ptr<Expansion2> expansion2;
    std::unique_ptr<gpu::GPU> gpu;
    std::unique_ptr<Interrupt> interrupt;
    std::unique_ptr<mdec::MDEC> mdec;
    std::unique_ptr<MemoryControl> memoryControl;
    std::unique_ptr<RamControl> ramControl;
    std::unique_ptr<Serial> serial;
    std::unique_ptr<spu::SPU> spu;
    
    std::vector<std::unique_ptr<device::timer::Timer>> timers;
    
    template <typename T>
    constexpr T fast_read(uint8_t*, uint32_t);
    
    template <typename T>
    constexpr void fast_write(uint8_t*, uint32_t, T);
    
    template <typename T, typename Peripheral>
    constexpr std::optional<T> read_peripheral(Peripheral&, uint32_t);
    
    template <typename T, typename Peripheral>
    constexpr void write_peripheral(Peripheral&, uint32_t, T);
    
    template<typename T, typename Peripheral>
    constexpr std::optional<T> read_io(uint32_t, uint32_t, uint32_t, Peripheral&);
    
    template<typename T, typename Peripheral>
    constexpr bool write_io(uint32_t, T, uint32_t, uint32_t, Peripheral&);
    
    template <typename T = uint32_t>
    T read(uint32_t);
    
    template <typename T = uint32_t>
    void write(uint32_t, T);
    
    constexpr void step(int /* count */ = 1);
    
    using PeripheralTypes = std::variant<device::dma::DMA*, Expansion2*, gpu::GPU*, Interrupt*, mdec::MDEC*, MemoryControl*, RamControl*, CacheControl*, Serial*>;
    
    template <typename Peripheral>
    constexpr void reset_peripheral(Peripheral&);
    
    constexpr bool reset(bool /* soft */ = true);
    
    bool load(const std::string& /* path */);
    bool load(const std::vector<uint8_t>& /* data */, const bool /* is_exe */ = false);
    
    enum HandleType : uint32_t { BIOS = 0, SYSTEM_CALL = 1 };
    void handle(HandleType);

    System();
    void printFunctionInfo(const char* functionNum, const bios::Function& f);
    void emulateFrame();
    bool isSystemReady();

    // Helpers
    std::string biosPath;
    int biosLog = 0;
    bool printStackTrace = false;
    void dumpRam();

#ifdef ENABLE_IO_LOG
    struct IO_LOG_ENTRY {
        enum class MODE { READ, WRITE } mode;

        uint32_t size;
        uint32_t addr;
        uint32_t data;
        uint32_t pc;
    };

    std::vector<IO_LOG_ENTRY> ioLogList;
#endif

    template <class Archive>
    void serialize(Archive& ar) {
        ar(*cpu);
        ar(*gpu);
        ar(*spu);
        ar(*interrupt);
        ar(*dma);
        ar(*cdrom);
        ar(*memoryControl);
        ar(*cacheControl);
        ar(*serial);
        ar(*mdec);
        ar(*controller);
        for (auto i : std::views::iota(0, 3))
            ar(*timers.at(i));

        ar(ram);
        ar(scratchpad);
    }
};
