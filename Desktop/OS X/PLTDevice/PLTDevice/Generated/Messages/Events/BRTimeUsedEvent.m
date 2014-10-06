//
//  BRTimeUsedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTimeUsedEvent.h"
#import "BRMessage_Private.h"




@interface BRTimeUsedEvent ()

@property(nonatomic,assign,readwrite) uint16_t totalTime;


@end


@implementation BRTimeUsedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TIME_USED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"totalTime", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTimeUsedEvent %p> totalTime=0x%04X",
            self, self.totalTime];
}

@end
