//
//  BRSetPowerLevelCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetPowerLevelCommand.h"
#import "BRMessage_Private.h"


const uint8_t SetPowerLevelCommand_PowerLevel_powerLevelFixedLow = 0;
const uint8_t SetPowerLevelCommand_PowerLevel_powerLevelAdaptiveMedium = 1;
const uint8_t SetPowerLevelCommand_PowerLevel_powerLevelAdaptiveHigh = 2;


@implementation BRSetPowerLevelCommand

#pragma mark - Public

+ (BRSetPowerLevelCommand *)commandWithPowerLevel:(uint8_t)powerLevel
{
	BRSetPowerLevelCommand *instance = [[BRSetPowerLevelCommand alloc] init];
	instance.powerLevel = powerLevel;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_POWER_LEVEL;
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
    return [NSString stringWithFormat:@"<BRSetPowerLevelCommand %p> powerLevel=0x%02X",
            self, self.powerLevel];
}

@end
