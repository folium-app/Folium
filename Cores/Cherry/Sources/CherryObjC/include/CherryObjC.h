//
//  CherryObjC.h
//  Cherry
//
//  Created by Jarrod Norwell on 22/12/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern void update(uint32_t* fb);

@interface CherryObjC : NSObject
@property (nonatomic, strong, nullable) void (^buffer) (uint32_t*);

+(CherryObjC *) sharedInstance NS_SWIFT_NAME(shared());

-(void) insertCartridge:(NSURL *)url;

-(void) step;

-(NSString *) gameID:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
