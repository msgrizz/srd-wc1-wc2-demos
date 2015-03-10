//
//  BRPowerLevelSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRPowerLevelSettingResult.h"
#import "BRMessage_Private.h"


@interface BRPowerLevelSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t powerLevel;


@end


@implementation BRPowerLevelSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_POWER_LEVEL_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"powerLevel", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPowerLevelSettingResult %p> powerLevel=0x%02X",
            self, self.powerLevel];
}

@end
