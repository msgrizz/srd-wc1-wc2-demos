//
//  BRTimeUsedSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTimeUsedSettingResult.h"
#import "BRMessage_Private.h"


@interface BRTimeUsedSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t totalTime;


@end


@implementation BRTimeUsedSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TIME_USED_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRTimeUsedSettingResult %p> totalTime=0x%04X",
            self, self.totalTime];
}

@end
