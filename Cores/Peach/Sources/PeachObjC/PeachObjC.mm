//
//  PeachObjC.m
//  Peach
//
//  Created by Jarrod Norwell on 22/2/2025.
//

#import "PeachObjC.h"

@implementation PeachObjC
+(PeachObjC *) sharedInstance {
    static PeachObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) insertCartridge:(NSURL *)url {
    emulator = std::make_unique<NES::Emulator>([url.path UTF8String]);
    emulator->reset();
}

-(void) step {
    emulator->step();
}

-(uint32_t*) framebuffer {
    return emulator->get_screen_buffer();
}

-(int) width {
    return NES::Emulator::WIDTH;
}

-(int) height {
    return NES::Emulator::HEIGHT;
}

-(void) button:(uint8_t)button player:(int)player pressed:(BOOL)pressed; {
    if (pressed)
        emulator->get_controller(0)[0] |= button;
    else
        emulator->get_controller(0)[0] &= ~button;
}
@end
