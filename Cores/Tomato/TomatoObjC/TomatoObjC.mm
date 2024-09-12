//
//  TomatoObjC.m
//  Tomato
//
//  Created by Jarrod Norwell on 12/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

#import "TomatoObjC.h"

#include "libgambatte/gambatte.h"

using namespace gambatte;

GB gameboyEmulator;

uint32_t *gbAB = new uint32_t[1], *gbFB = new uint32_t[160 * 140];

@implementation TomatoObjC
+(TomatoObjC *) sharedInstance {
    static TomatoObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
@end
