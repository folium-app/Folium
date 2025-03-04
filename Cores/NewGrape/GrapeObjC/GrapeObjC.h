//
//  GrapeObjC.h
//  NewGrape
//
//  Created by Jarrod Norwell on 4/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrapeObjC : NSObject
+(GrapeObjC *) sharedInstance NS_SWIFT_NAME(shared());

-(void) insertCartridge:(NSURL *)url NS_SWIFT_NAME(insert(cartridge:));
@end

NS_ASSUME_NONNULL_END
