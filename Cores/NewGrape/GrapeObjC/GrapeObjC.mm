//
//  GrapeObjC.mm
//  NewGrape
//
//  Created by Jarrod Norwell on 4/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

#import "GrapeObjC.h"

#include "Platform.h"
#include "NDS.h"
#include "SPU.h"
#include "GPU.h"
#include "AREngine.h"

#include "Config.h"

Config::Table globalTable{Config::GetGlobalTable()};
Config::Table localTable{Config::GetLocalTable(0)};

int consoleType;
melonDS::NDS* nds = nullptr;

@implementation GrapeObjC
+(GrapeObjC *) sharedInstance {
    static GrapeObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) insertCartridge:(NSURL *)url {
    
}
@end
