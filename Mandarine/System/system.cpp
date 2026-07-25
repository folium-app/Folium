#include "avocado/system.h"
#include <fmt/core.h>
#include <fmt/format.h>
#include <fmt/format-inl.h>
#include "avocado/bios/functions.h"
#include "avocado/config.h"
#include "avocado/sound/sound.h"
#include "avocado/utils/address.h"
#include "avocado/utils/gpu_draw_list.h"
#include "avocado/utils/file.h"
#include "avocado/utils/psx_exe.h"

#include <variant>
#include <vector>

#ifdef ENABLE_IO_LOG
#define LOG_IO(mode, size, addr, data, pc) ioLogList.push_back({(mode), (size), (addr), (data), (pc)})
#else
#define LOG_IO(mode, size, addr, data, pc)
#endif

#define READ_IO32(begin, end, periph)                                                                                    \
    if (aligned_address >= (begin) && aligned_address < (end)) {                                                                               \
        T data = 0;                                                                                                      \
        if (sizeof(T) == 4) {                                                                                            \
            data = (periph)->read(aligned_address - (begin));                                                                       \
        } else {                                                                                                         \
            fmt::print("[SYS] R Unsupported access to " #periph " with bit size {}\n", static_cast<int>(sizeof(T) * 8)); \
        }                                                                                                                \
                                                                                                                         \
        LOG_IO(IO_LOG_ENTRY::MODE::READ, sizeof(T) * 8, address, data, cpu->PC);                                         \
        return data;                                                                                                     \
    }

#define WRITE_IO32(begin, end, periph)                                                                                   \
    if (aligned_address >= (begin) && aligned_address < (end)) {                                                                               \
        if (sizeof(T) == 4) {                                                                                            \
            (periph)->write(aligned_address - (begin), value);                                                                       \
        } else {                                                                                                         \
            fmt::print("[SYS] W Unsupported access to " #periph " with bit size {}\n", static_cast<int>(sizeof(T) * 8)); \
        }                                                                                                                \
                                                                                                                         \
        LOG_IO(IO_LOG_ENTRY::MODE::WRITE, sizeof(T) * 8, address, value, cpu->PC);                                        \
        return;                                                                                                          \
    }

System::System() {
    bios.resize(constants::bios::SIZE);
    expansion_region_1.resize(constants::expansion::REGION_1_SIZE);
    if (config.options.system.ram8mb)
        ram.resize(constants::ram::SIZE_8MB);
    else
        ram.resize(constants::ram::SIZE_2MB);
    scratchpad.resize(constants::scratchpad::SIZE);
    
    for (auto vec : {&bios, &expansion_region_1, &ram, &scratchpad})
        std::fill(vec->begin(), vec->end(), 0);
    
    timers.resize(constants::timers::SIZE);
    std::fill(timers.begin(), timers.end(), nullptr);
    
    cpu = std::make_unique<mips::CPU>(this);
    gpu = std::make_unique<gpu::GPU>(this);
    spu = std::make_unique<spu::SPU>(this);
    mdec = std::make_unique<mdec::MDEC>();

    cdrom = std::make_unique<device::cdrom::CDROM>(this);
    controller = std::make_unique<device::controller::Controller>(this);
    dma = std::make_unique<device::dma::DMA>(this);
    expansion2 = std::make_unique<Expansion2>();
    interrupt = std::make_unique<Interrupt>(this);
    memoryControl = std::make_unique<MemoryControl>();
    ramControl = std::make_unique<RamControl>();
    cacheControl = std::make_unique<CacheControl>(this);
    serial = std::make_unique<Serial>();
    
    for (auto i : std::views::iota(0, 3))
        timers.at(i) = std::make_unique<device::timer::Timer>(this, i);

    debugOutput = config.debug.log.system;
    biosLog = config.debug.log.bios;

    cycles = 0;
}

template <typename T>
constexpr T System::fast_read(uint8_t* device, uint32_t address) {
    std::vector<bool> checklist{
        std::is_same_v<T, uint8_t>,
        std::is_same_v<T, uint16_t>,
        std::is_same_v<T, uint32_t>
    };
    assert(std::any_of(checklist.begin(), checklist.end(), [](bool result) { return result; }));
    
    switch (sizeof(T)) {
        case sizeof(uint8_t):
            return static_cast<T>(device[address]);
        case sizeof(uint16_t):
            return static_cast<T>(((uint16_t*)device)[address / sizeof(uint16_t)]);
        case sizeof(uint32_t):
            return static_cast<T>(((uint32_t*)device)[address / sizeof(uint32_t)]);
        default:
            return 0;
    }
}

template <typename T>
constexpr void System::fast_write(uint8_t* device, uint32_t address, T value) {
    std::vector<bool> checklist{
        std::is_same_v<T, uint8_t>,
        std::is_same_v<T, uint16_t>,
        std::is_same_v<T, uint32_t>
    };
    assert(std::any_of(checklist.begin(), checklist.end(), [](bool result) { return result; }));
    
    switch (sizeof(T)) {
        case sizeof(uint8_t):
            ((uint8_t*)device)[address] = static_cast<uint8_t>(value);
            break;
        case sizeof(uint16_t):
            ((uint16_t*)device)[address / sizeof(uint16_t)] = static_cast<uint16_t>(value);
            break;
        case sizeof(uint32_t):
            ((uint32_t*)device)[address / sizeof(uint32_t)] = static_cast<uint32_t>(value);
            break;
        default:
            break;
    }
}

template <typename T, typename Peripheral>
constexpr std::optional<T> System::read_peripheral(Peripheral& peripheral, uint32_t address) {
    std::vector<bool> checklist{
        std::is_same_v<T, uint8_t>,
        std::is_same_v<T, uint16_t>,
        std::is_same_v<T, uint32_t>
    };
    assert(std::any_of(checklist.begin(), checklist.end(), [](bool result) { return result; }));
    
    switch (sizeof(T)) {
        case sizeof(uint8_t):
            return peripheral->read(address);
        case sizeof(uint16_t):
            return peripheral->read(address) | peripheral->read(address + 1) << 8;
        case sizeof(uint32_t):
            return peripheral->read(address) | peripheral->read(address + 1) << 8 |  peripheral->read(address + 2) << 16 | peripheral->read(address + 3) << 24;
        default:
            return std::nullopt;
    }
}

template <typename T, typename Peripheral>
constexpr void System::write_peripheral(Peripheral& peripheral, uint32_t address, T value) {
    std::vector<bool> checklist{
        std::is_same_v<T, uint8_t>,
        std::is_same_v<T, uint16_t>,
        std::is_same_v<T, uint32_t>
    };
    assert(std::any_of(checklist.begin(), checklist.end(), [](bool result) { return result; }));
    
    switch (sizeof(T)) {
        case sizeof(uint8_t):
            peripheral->write(address, static_cast<uint8_t>(value) & 0xFF);
            break;
        case sizeof(uint16_t):
            peripheral->write(address, static_cast<uint16_t>(value) & 0xFF);
            peripheral->write(address + 1, static_cast<uint16_t>(value >> 8) & 0xFF);
            break;
        case sizeof(uint32_t):
            peripheral->write(address, static_cast<uint32_t>(value) & 0xFF);
            peripheral->write(address + 1, static_cast<uint32_t>(value >> 8) & 0xFF);
            peripheral->write(address + 2, static_cast<uint32_t>(value >> 16) & 0xFF);
            peripheral->write(address + 3, static_cast<uint32_t>(value >> 24) & 0xFF);
            break;
        default:
            break;
    }
}

template<typename T, typename Peripheral>
constexpr std::optional<T> System::read_io(uint32_t address, uint32_t begin, uint32_t end, Peripheral& peripheral) {
    if (address >= begin && address < end)
        return read_peripheral<T, Peripheral>(peripheral, address - begin);
    return std::nullopt;
}

template<typename T, typename Peripheral>
constexpr bool System::write_io(uint32_t address, T value, uint32_t begin, uint32_t end, Peripheral& peripheral) {
    if (address >= begin && address < end) {
        write_peripheral<T, Peripheral>(peripheral, address - begin, value);
        return true;
    } else
        return false;
}

template <typename T>
T System::read(uint32_t address) {
    std::vector<bool> checklist{
        std::is_same_v<T, uint8_t>,
        std::is_same_v<T, uint16_t>,
        std::is_same_v<T, uint32_t>
    };
    assert(std::any_of(checklist.begin(), checklist.end(), [](bool result) { return result; }));

    uint32_t aligned_address = align_mips<T>(address);

    if (in_range<constants::ram::BASE, constants::ram::SIZE_8MB>(aligned_address))
        return fast_read<T>(ram.data(), (aligned_address - constants::ram::BASE) & (ram.size() - 1));
    
    if (in_range<constants::expansion::REGION_1_BASE, constants::expansion::REGION_1_SIZE>(aligned_address))
        return fast_read<T>(expansion_region_1.data(), aligned_address - constants::expansion::REGION_1_BASE);
    
    if (in_range<constants::scratchpad::BASE, constants::scratchpad::SIZE>(aligned_address))
        return fast_read<T>(scratchpad.data(), aligned_address - constants::scratchpad::BASE);
    
    if (in_range<constants::bios::BASE, constants::bios::SIZE>(aligned_address))
        return fast_read<T>(bios.data(), aligned_address - constants::bios::BASE);
    
    std::vector<std::optional<T>> read_io_results{
        read_io<T>(aligned_address, constants::io::MEMORY_CONTROL_START, constants::io::MEMORY_CONTROL_END, memoryControl),
        read_io<T>(aligned_address, constants::io::CONTROLLER_START, constants::io::CONTROLLER_END, controller),
        read_io<T>(aligned_address, constants::io::SERIAL_START, constants::io::SERIAL_END, serial),
        read_io<T>(aligned_address, constants::io::RAM_CONTROL_START, constants::io::RAM_CONTROL_END, ramControl),
        read_io<T>(aligned_address, constants::io::INTERRUPT_START, constants::io::INTERRUPT_END, interrupt),
        read_io<T>(aligned_address, constants::io::DMA_START, constants::io::DMA_END, dma),
        read_io<T>(aligned_address, constants::io::TIMER_1_START, constants::io::TIMER_1_END, timers.at(0)),
        read_io<T>(aligned_address, constants::io::TIMER_2_START, constants::io::TIMER_2_END, timers.at(1)),
        read_io<T>(aligned_address, constants::io::TIMER_3_START, constants::io::TIMER_3_END, timers.at(2)),
        read_io<T>(aligned_address, constants::io::CDROM_START, constants::io::CDROM_END, cdrom),
        
        read_io<T>(aligned_address, constants::io::SPU_START, constants::io::SPU_END, spu),
        read_io<T>(aligned_address, constants::io::EXPANSION_2_START, constants::io::EXPANSION_2_END, expansion2)
    };
    
    for (auto result : read_io_results)
        if (result.has_value())
            return result.value();

    READ_IO32(0x1f801810, 0x1f801818, gpu);
    READ_IO32(0x1f801820, 0x1f801828, mdec);

    if (in_range<0xfffe0130, 4>(address) && sizeof(T) == sizeof(uint32_t)) {
        auto data = cacheControl->read(0);
        return data;
    }
    
    // Gran Tursimo 2
    if (in_range<0x1f801130, 16>(address) && sizeof(T) == sizeof(uint16_t))
        return 0;

    std::string num{"32"};
    switch (sizeof(T)) {
        case sizeof(uint8_t):
            num = "8";
            break;
        case sizeof(uint16_t):
            num = "16";
            break;
        case sizeof(uint32_t):
            num = "32";
            break;
        default:
            break;
    }
    
    fmt::print("[SYSTEM:{}{}]: unhandled read from address 0x{:08X} of size {}\n", __func__, num, address, sizeof(T));
    cpu->busError();

    return 0;
}

template uint8_t System::read<uint8_t>(uint32_t);
template uint16_t System::read<uint16_t>(uint32_t);
template uint32_t System::read<uint32_t>(uint32_t);

template <typename T>
void System::write(uint32_t address, T value) {
    std::vector<bool> checklist{
        std::is_same_v<T, uint8_t>,
        std::is_same_v<T, uint16_t>,
        std::is_same_v<T, uint32_t>
    };
    assert(std::any_of(checklist.begin(), checklist.end(), [](bool result) { return result; }));

    if (unlikely(cpu->cop0.status.isolateCache)) {
        uint32_t tag = (address & 0xfffff000) >> 12;
        uint16_t index = (address & 0xffc) >> 2;
        cpu->icache[index] = mips::CacheLine{tag, value};
        return;
    }

    uint32_t aligned_address = align_mips<T>(address);

    if (in_range<constants::ram::BASE, constants::ram::SIZE_8MB>(aligned_address))
        return fast_write<T>(ram.data(), (aligned_address - constants::ram::BASE) & (ram.size() - 1), value);
    
    if (in_range<constants::expansion::REGION_1_BASE, constants::expansion::REGION_1_SIZE>(aligned_address))
        return fast_write<T>(expansion_region_1.data(), aligned_address - constants::expansion::REGION_1_BASE, value);
    
    if (in_range<constants::scratchpad::BASE, constants::scratchpad::SIZE>(aligned_address))
        return fast_write<T>(scratchpad.data(), aligned_address - constants::scratchpad::BASE, value);
    
    std::vector<bool> write_io_results{
        write_io<T>(aligned_address, value, constants::io::MEMORY_CONTROL_START, constants::io::MEMORY_CONTROL_END, memoryControl),
        write_io<T>(aligned_address, value, constants::io::CONTROLLER_START, constants::io::CONTROLLER_END, controller),
        write_io<T>(aligned_address, value, constants::io::SERIAL_START, constants::io::SERIAL_END, serial),
        write_io<T>(aligned_address, value, constants::io::RAM_CONTROL_START, constants::io::RAM_CONTROL_END, ramControl),
        write_io<T>(aligned_address, value, constants::io::INTERRUPT_START, constants::io::INTERRUPT_END, interrupt),
        write_io<T>(aligned_address, value, constants::io::DMA_START, constants::io::DMA_END, dma),
        write_io<T>(aligned_address, value, constants::io::TIMER_1_START, constants::io::TIMER_1_END, timers.at(0)),
        write_io<T>(aligned_address, value, constants::io::TIMER_2_START, constants::io::TIMER_2_END, timers.at(1)),
        write_io<T>(aligned_address, value, constants::io::TIMER_3_START, constants::io::TIMER_3_END, timers.at(2)),
        write_io<T>(aligned_address, value, constants::io::CDROM_START, constants::io::CDROM_END, cdrom),
        
        write_io<T>(aligned_address, value, constants::io::SPU_START, constants::io::SPU_END, spu),
        write_io<T>(aligned_address, value, constants::io::EXPANSION_2_START, constants::io::EXPANSION_2_END, expansion2)
    };
    
    for (auto result : write_io_results)
        if (result)
            return;
    
    WRITE_IO32(0x1f801810, 0x1f801818, gpu);
    WRITE_IO32(0x1f801820, 0x1f801828, mdec);

    if (in_range<0xfffe0130, 4>(address) && sizeof(T) == sizeof(uint32_t)) {
        cacheControl->write(0, value);
        return;
    }

    std::string num{"32"};
    switch (sizeof(T)) {
        case sizeof(uint8_t):
            num = "8";
            break;
        case sizeof(uint16_t):
            num = "16";
            break;
        case sizeof(uint32_t):
            num = "32";
            break;
        default:
            break;
    }
    
    fmt::print("[SYSTEM:{}{}]: unhandled write to address 0x{:08X} with value {} of size {}\n", __func__, num, address, value, sizeof(T));
    
    cpu->busError();
}

template void System::write<uint8_t>(uint32_t, uint8_t);
template void System::write<uint16_t>(uint32_t, uint16_t);
template void System::write<uint32_t>(uint32_t, uint32_t);

constexpr void System::step(int count) {
    state = State::run;
    cpu->executeInstructions(1);
    state = State::pause;

    dma->step();
    cdrom->step(3);
    timers.at(0)->step(3);
    timers.at(1)->step(3);
    timers.at(2)->step(3);
    controller->step();
    spu->step(cdrom.get());

    if (gpu->emulateGpuCycles(3))
        interrupt->trigger(interrupt::VBLANK);
}

template <typename Peripheral>
constexpr void System::reset_peripheral(Peripheral& peripheral) {
    std::visit([](auto* peripheral) {
        peripheral->reset();
    }, peripheral);
}

constexpr bool System::reset(bool soft) {
    std::vector<PeripheralTypes> peripherals{
        dma.get(),
        expansion2.get(),
        gpu.get(),
        interrupt.get(),
        mdec.get(),
        memoryControl.get(),
        ramControl.get(),
        cacheControl.get(),
        serial.get()
    };
    
    for (auto& peripheral : peripherals)
        reset_peripheral(peripheral);
    
    cpu->setPC(0xBFC00000);
    cpu->inBranchDelay = false;
    state = State::run;
    
    return true;
}

bool System::load(const std::string& path) {
    const char* licenseString = "Sony Computer Entertainment Inc";

    auto _bios = getFileContents(path);
    if (_bios.empty()) {
        fmt::print("[SYS] Cannot open BIOS {}\n", path);
        return false;
    }
    assert(_bios.size() <= 512 * 1024);

    if (memcmp(_bios.data() + 0x108, licenseString, strlen(licenseString)) != 0) {
        fmt::print("[WARNING]: Loaded bios ({}) have invalid header, are you using correct file?\n", getFilenameExt(path));
    }

    std::copy(_bios.begin(), _bios.end(), bios.begin());
    this->biosPath = path;
    state = State::run;
    biosLoaded = true;

    auto patch = [&](uint32_t address, uint32_t opcode) {
        address &= bios.size() - 1;
        for (int i = 0; i < 4; i++) {
            bios[address + i] = (opcode >> (i * 8)) & 0xff;
        }
    };

    if (config.debug.log.system) {
        fmt::print("[INFO] Patching BIOS for system log\n");
        patch(0x6F0C, 0x24010001);
        patch(0x6F14, 0xAF81A9C0);
    }

    return true;
}

bool System::load(const std::vector<uint8_t>& data, const bool is_exe) {
    if (is_exe) {
        if (data.empty()) return false;
        assert(data.size() >= 0x800);

        PsxExe exe;
        memcpy(&exe, data.data(), sizeof(exe));

        if (exe.t_size > data.size() - 0x800) {
            fmt::print("Invalid exe t_size: 0x{:08x}\n", exe.t_size);
            exe.t_size = data.size() - 0x800;
        }

        for (uint32_t i = 0; i < exe.t_size; i++) {
            write<uint8_t>(exe.t_addr + i, data[0x800 + i]);
        }

        cpu->setPC(exe.pc0);
        cpu->setReg(28, exe.gp0);

        if (exe.s_addr != 0) {
            cpu->setReg(29, exe.s_addr + exe.s_size);
            cpu->setReg(30, exe.s_addr + exe.s_size);
        }

        cpu->inBranchDelay = false;

        return true;
    } else {
        assert(data.size() <= constants::expansion::REGION_1_SIZE);
        
        if (data.empty())
            return false;

        const std::string license{"Licensed by Sony Computer Entertainment Inc"};
        if (memcmp(data.data() + 4, license.c_str(), strlen(license.c_str())) != 0)
            fmt::print("[WARN]: Loaded expansion have invalid header, are you using correct file?\n");

        std::copy(data.begin(), data.end(), expansion_region_1.begin());
        
        return true;
    }
}

void System::printFunctionInfo(const char* functionNum, const bios::Function& f) {
    fmt::print("  {}: {}(", functionNum, f.name);
    unsigned int a = 0;
    for (auto arg : f.args) {
        uint32_t param = cpu->reg[4 + a];
        if (true) {
            fmt::print("{} = ", arg.name);
        }
        switch (arg.type) {
            case bios::Type::INT:
            case bios::Type::POINTER: fmt::print("0x{:x}", param); break;
            case bios::Type::CHAR: fmt::print("'{:c}'", (char)param); break;
            case bios::Type::STRING: {
                fmt::print("\"");
                for (int i = 0; i < 32; i++) {
                    uint8_t c = read<uint8_t>(param + i);

                    if (c == 0) {
                        break;
                    } else if (c != 0 && i == 32 - 1) {
                        fmt::print("...");
                    } else {
                        fmt::print("{:c}", isprint(c) ? (char)c : '_');
                    }
                }
                fmt::print("\"");
                break;
            }
        }
        if (a < (f.args.size() - 1)) {
            fmt::print(", ");
        }
        a++;
        if (a > 4) break;
    }
    fmt::print(")\n");
}

void System::handleBiosFunction() {
    uint32_t maskedPC = cpu->PC & 0x1FFFFF;
    uint8_t functionNumber = cpu->reg[9];
    bool log = biosLog;

    int tableNum = (maskedPC - 0xA0) / 0x10;
    if (tableNum > 2) return;

    const auto& table = bios::tables[tableNum];
    const auto& function = table.find(functionNumber);

    if (function == table.end()) {
        fmt::print("  BIOS {:1X}(0x{:02X}): Unknown function!\n", 0xA + tableNum, functionNumber);
        return;
    }
    if (function->second.callback != nullptr) {
        log = function->second.callback(this);
    }

    if (log) {
        std::string type = fmt::format("BIOS {:1X}({:02X})", 0xA + tableNum, functionNumber);
        printFunctionInfo(type.c_str(), function->second);
    }
}

void System::handleSyscallFunction() {
    uint8_t functionNumber = cpu->reg[4];
    bool log = biosLog;

    const auto& function = bios::SYSCALL.find(functionNumber);
    if (function == bios::SYSCALL.end()) return;

    if (function->second.callback != nullptr) {
        log = function->second.callback(this);
    }

    if (log) {
        std::string type = fmt::format("SYSCALL({:X})", functionNumber);
        cpu->sys->printFunctionInfo(type.c_str(), function->second);
    }
}

void System::emulateFrame() {
#ifdef ENABLE_IO_LOG
    ioLogList.clear();
#endif
    cpu->gte.log.clear();

    if (GpuDrawList::currentFrame == 0) {
        gpu->prevVram = gpu->vram;

        // Save initial state
        if (gpu->gpuLogEnabled) {
            gpu->gpuLogList.clear();
            GpuDrawList::dumpInitialState(gpu.get());
        }
    }

    if (++GpuDrawList::currentFrame >= GpuDrawList::framesToCapture) {
        GpuDrawList::currentFrame = 0;
        if (GpuDrawList::framesToCapture != 0) {
            toast(fmt::format("{} frames capture complete", GpuDrawList::framesToCapture));
            GpuDrawList::framesToCapture = 0;
            state = State::pause;
            return;
        }
    }

    int systemCycles = 300;
    for (;;) {
        if (!cpu->executeInstructions(systemCycles / 3)) {
            return;
        }

        dma->step();
        cdrom->step(systemCycles / 1.5f);
        timers.at(0)->step(systemCycles);
        timers.at(1)->step(systemCycles);
        timers.at(2)->step(systemCycles);

        static float spuCounter = 0;

        float magicNumber = 1.575f;
        if (!gpu->isNtsc()) {
            // Hack to prevent crackling audio on PAL games
            // Note - this overclocks SPU clock, bugs might appear.
            magicNumber *= 50.f / 60.f;
        }
        spuCounter += (float)systemCycles / magicNumber / (float)0x300;
        if (spuCounter >= 1.f) {
            spu->step(cdrom.get());
            spuCounter -= 1.0f;
        }

        if (spu->bufferReady) {
            spu->bufferReady = false;
            Sound::appendBuffer(spu->audioBuffer.begin(), spu->audioBuffer.end());
        }

        controller->step();

        if (gpu->emulateGpuCycles(systemCycles)) {
            interrupt->trigger(interrupt::VBLANK);
            return;  // frame emulated
        }

        // TODO: Move this code to Timer class
        if (gpu->gpuLine > gpu->linesPerFrame() - 20) {
            auto& t = *timers.at(1);
            if (t.mode.syncEnabled) {
                using modes = device::timer::CounterMode::SyncMode1;
                auto mode1 = static_cast<modes>(timers.at(1)->mode.syncMode);
                if (mode1 == modes::resetAtVblank || mode1 == modes::resetAtVblankAndPauseOutside) {
                    timers.at(1)->current._reg = 0;
                } else if (mode1 == modes::pauseUntilVblankAndFreerun) {
                    timers.at(1)->paused = false;
                    timers.at(1)->mode.syncEnabled = false;
                }
            }
        }
        // Handle Timer1 - Reset on VBlank
    }
}

bool System::isSystemReady() { return biosLoaded; }

void System::dumpRam() {
    writeToDisc("ram.bin", ram);
}
