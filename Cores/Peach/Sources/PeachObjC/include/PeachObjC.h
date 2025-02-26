//
//  PeachObjC.h
//  Peach
//
//  Created by Jarrod Norwell on 22/2/2025.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <memory>

#include "emulator.hpp"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PeachObjC : NSObject {
#ifdef __cplusplus
    std::unique_ptr<NES::Emulator> emulator;
#endif
}

+(PeachObjC *) sharedInstance NS_SWIFT_NAME(shared());

-(void) insertCartridge:(NSURL *)url NS_SWIFT_NAME(insert(cartridge:));
-(void) step NS_SWIFT_NAME(step());

-(uint32_t*) framebuffer NS_SWIFT_NAME(framebuffer());

-(int) width;
-(int) height;

-(void) button:(uint8_t)button player:(int)player pressed:(BOOL)pressed;
@end

NS_ASSUME_NONNULL_END
