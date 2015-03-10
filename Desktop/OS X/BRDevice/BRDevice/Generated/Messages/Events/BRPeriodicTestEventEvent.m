//
//  BRPeriodicTestEventEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRPeriodicTestEventEvent.h"
#import "BRMessage_Private.h"


@interface BRPeriodicTestEventEvent ()

@property(nonatomic,assign,readwrite) int32_t time;
@property(nonatomic,strong,readwrite) NSData * byteArray;


@end


@implementation BRPeriodicTestEventEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PERIODIC_TEST_EVENT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"time", @"type": @(BRPayloadItemTypeLong)},
			@{@"name": @"byteArray", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPeriodicTestEventEvent %p> time=0x%08X, byteArray=%@",
            self, self.time, self.byteArray];
}

@end
