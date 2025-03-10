//
//  GuavaObjC.h
//  Guava
//
//  Created by Jarrod Norwell on 7/3/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuavaObjC : NSObject
@property (nonatomic, strong) void (^framebufferRGBA5551) (uint16_t*, int, int);
@property (nonatomic, strong) void (^framebufferABGR8888) (const uint8_t*, int, int);

+(GuavaObjC *) sharedInstance NS_SWIFT_NAME(shared());

-(void) insertCartridge:(NSURL *)url;
-(void) step;
@end

NS_ASSUME_NONNULL_END
