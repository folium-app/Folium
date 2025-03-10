//
//  GuavaObjC.mm
//  Guava
//
//  Created by Jarrod Norwell on 7/3/2025.
//

#import "GuavaObjC.h"

#include <memory>

#include "n64.h"

std::unique_ptr<N64> emulator;

void render_screen(const N64& n64) {
    const VI& vi = n64.mmu().vi();

    const auto width = Common::bit_range<11, 0>(vi.width());
    const auto v_video = vi.vstart();
    const auto v_start = Common::bit_range<25, 16>(v_video);
    const auto v_end = Common::bit_range<9, 0>(v_video);
    const auto y_scale = Common::bit_range<11, 10>(vi.yscale()); // FIXME: Handle fractional bits
    const auto height = ((v_end - v_start) / 2) * y_scale;
    const auto origin = Common::bit_range<23, 0>(vi.origin());
    const auto color_format = Common::bit_range<1, 0>(vi.control());
    
    switch (color_format) {
        case 0:
        default:
            break;
        case 2: {
            std::vector<u16> pixel_buffer(width * height);
            
            for (std::size_t y = 0; y < height; y++) {
                for (std::size_t x = 0; x < width; x++) {
                    const auto pixel_buffer_offset = (y * width + x);
                    const auto rdram_offset = origin + (pixel_buffer_offset * sizeof(u16));
                    
                    u16 color = n64.mmu().rdram().at(rdram_offset) << 8;
                    color |= n64.mmu().rdram().at(rdram_offset + 1);
                    pixel_buffer.at(pixel_buffer_offset) = color;
                }
            }
            
            if (auto buffer = [[GuavaObjC sharedInstance] framebufferRGBA5551])
                buffer(pixel_buffer.data(), width, height);
            
            break;
        }
        case 3: {
            if (auto buffer = [[GuavaObjC sharedInstance] framebufferABGR8888]) {
                auto buf = static_cast<const u8*>(n64.mmu().rdram().data() + origin);
                buffer(buf, width, height);
            }
            break;
        }
    }
}

void handle_frontend_events() {}

@implementation GuavaObjC
+(GuavaObjC *) sharedInstance {
    static GuavaObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) insertCartridge:(NSURL *)url {
    NSURL *guavaDirectoryURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Guava"];
    
    PIF pif{[[[guavaDirectoryURL URLByAppendingPathComponent:@"sysdata"] URLByAppendingPathComponent:@"bios.bin"].path UTF8String]};
    GamePak pak{[url.path UTF8String]};
    
    emulator = std::make_unique<N64>(pif, pak);
}

-(void) step {
    emulator->run();
}
@end
