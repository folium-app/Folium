//
//  TomatoObjC.h
//  Tomato
//
//  Created by Jarrod Norwell on 12/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TomatoObjC : NSObject
+(TomatoObjC *) sharedInstance NS_SWIFT_NAME(shared());
@end

NS_ASSUME_NONNULL_END
