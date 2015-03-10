//
//  BRTimeUsedCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTimeUsedCommand.h"
#import "BRMessage_Private.h"


@implementation BRTimeUsedCommand

#pragma mark - Public

+ (BRTimeUsedCommand *)commandWithTotalTime:(uint16_t)totalTime
{
	BRTimeUsedCommand *instance = [[BRTimeUsedCommand alloc] init];
	instance.totalTime = totalTime;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TIME_USED;
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
    return [NSString stringWithFormat:@"<BRTimeUsedCommand %p> totalTime=0x%04X",
            self, self.totalTime];
}

@end
