/*
 * moestation is a WIP PlayStation 2 emulator.
 * Copyright (C) 2022-2023  Lady Starbreeze (Michelle-Marie Schiller)
 */
 
#include "core/moestation.hpp"

#include <cstdio>
#include <cstring>
#include <assert.h>

#include <ctype.h>

#include "core/scheduler.hpp"
#include "core/bus/bus.hpp"
#include "core/ee/cpu/cpu.hpp"
#include "core/ee/dmac/dmac.hpp"
#include "core/ee/timer/timer.hpp"
#include "core/ee/vif/vif.hpp"
#include "core/gs/gs.hpp"
#include "core/iop/iop.hpp"
#include "core/iop/cdrom/cdrom.hpp"
#include "core/iop/cdvd/cdvd.hpp"
#include "core/iop/dmac/dmac.hpp"
#include "core/iop/timer/timer.hpp"

namespace ps2 {
char execPath[256];
bool isRunning = true, psxFastBoot = false;

void set_path(const char* path) {
    if (std::strncmp("", "-PSXMODE", 8) == 0)
        psxFastBoot = true;

    std::strncpy(execPath, path, 256);
}

void enterPS1Mode() {
    iop::enterPS1Mode();
    iop::dmac::enterPS1Mode();
}

void fastBoot() {
    std::printf("[moestation] Fast booting \"%s\"...\n", execPath);
    
    char *ext = std::strrchr(execPath, '.');
    
    if (!ext) {
        std::printf("[moestation] No file extension found\n");
        
        exit(0);
    }
    
    if (std::strlen(ext) != 4) {
        std::printf("[moestation] Invalid file extension %s\n", ext);
        
        exit(0);
    }
    
    for (int i = 1; i < 4; i++) {
        ext[i] = tolower(ext[i]);
    }
    
    if ((std::strncmp(ext, ".iso", 4) == 0) || std::strncmp(ext, ".bin", 4) == 0) {
        std::printf("[moestation] Loading ISO...\n");
        
        if (psxFastBoot) {
            std::printf("[moestation] PSX fast boot\n");
            
            return bus::setPathEELOAD("rom0:PS1DRV");
        }
        
        char dvdPath[23] = "cdrom0:\\\\XXXX_000.00;1";
        
        iop::cdvd::getExecPath(dvdPath);
        
        bus::setPathEELOAD(dvdPath);
    } else if (std::strncmp(ext, ".elf", 4) == 0) {
        std::printf("[moestation] Loading ELF...\n");
        
        assert(false);
    } else {
        std::printf("[moestation] Invalid file extension %s\n", ext);
        
        exit(0);
    }
}

}
