//
//  CherryObjC.mm
//  Cherry
//
//  Created by Jarrod Norwell on 22/12/2024.
//

#import "CherryObjC.h"

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
#include "core/moestation.hpp"

#include <algorithm>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using VectorInterface = ps2::ee::vif::VectorInterface;
VectorInterface vif[2] = {VectorInterface(0, ps2::ee::cpu::getVU(0)), VectorInterface(1, ps2::ee::cpu::getVU(1))};

void update(uint32_t* fb) {
    if (const auto buffer = [[CherryObjC sharedInstance] buffer])
        buffer(fb);
}

size_t findSystemCnfForCherry(std::ifstream& file, size_t startOffset, size_t maxReadSize) {
    std::vector<char> buffer(maxReadSize);
    file.seekg(startOffset);
    file.read(buffer.data(), maxReadSize);
    size_t bytesRead = file.gcount();

    std::string content(buffer.begin(), buffer.begin() + bytesRead);
    size_t pos = content.find("SYSTEM.CNF");
    return (pos != std::string::npos) ? (startOffset + pos) : std::string::npos;
}

// Function to extract the PS2 game ID from a .bin file
std::string getGameID(const std::string& binFilePath) {
    const int blockSize = 1024 * 1024; // Read in 1MB blocks
    std::ifstream binFile(binFilePath, std::ios::binary);
    if (!binFile.is_open()) {
        throw std::runtime_error("Failed to open the .bin file");
    }

    binFile.seekg(0, std::ios::end);
    size_t fileSize = binFile.tellg();
    binFile.seekg(0, std::ios::beg);

    std::vector<char> buffer(blockSize);
    size_t bytesRead = 0;

    while (bytesRead < fileSize) {
        size_t readSize = std::min(blockSize, (int)(fileSize - bytesRead));
        binFile.read(buffer.data(), readSize);

        std::string content(buffer.begin(), buffer.begin() + readSize);
        size_t bootPos = content.find("BOOT");

        if (bootPos != std::string::npos) {
            // Extract the game ID
            size_t start = content.find("cdrom0:\\", bootPos) + 8;
            size_t end = content.find(';', start);

            if (start == std::string::npos || end == std::string::npos) {
                throw std::runtime_error("Invalid BOOT line format");
            }

            return content.substr(start, end - start);
        }

        bytesRead += readSize;
    }

    throw std::runtime_error("BOOT line not found in the file");
}

@implementation CherryObjC
+(CherryObjC *) sharedInstance {
    static CherryObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) insertCartridge:(NSURL *)url {
    ps2::set_path([url.path UTF8String]);
    ps2::scheduler::init();
    
    NSURL *cherryDirectoryURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Cherry"];
    
    ps2::bus::init([[[cherryDirectoryURL URLByAppendingPathComponent:@"sysdata"] URLByAppendingPathComponent:@"bios.bin"].path UTF8String], &vif[0], &vif[1]);

    ps2::ee::cpu::init();
    ps2::ee::dmac::init();
    ps2::ee::timer::init();
    
    ps2::gs::init();

    ps2::iop::init();
    ps2::iop::dmac::init();
    ps2::iop::timer::init();

    ps2::iop::cdvd::init([url.path UTF8String]);
    ps2::iop::cdrom::init([url.path UTF8String]);

    ps2::scheduler::flush();
}

-(void) step {
    const auto runCycles = ps2::scheduler::getRunCycles();

    ps2::scheduler::processEvents(runCycles);

    ps2::ee::cpu::step(runCycles);
    ps2::ee::timer::step(runCycles >> 1);

    ps2::iop::step(runCycles >> 3);
    ps2::iop::timer::step(runCycles >> 3);

    ps2::scheduler::flush();
}

-(NSString *) gameID:(NSURL *)url {
    NSString *string = @"";
    try {
        string = [NSString stringWithCString:getGameID([url.path UTF8String]).c_str() encoding:NSUTF8StringEncoding];
    } catch (std::runtime_error& e) {
        NSLog(@"%@", [NSString stringWithCString:e.what() encoding:NSUTF8StringEncoding]);
        string = @"";
    }
    
    return string;
}
@end
