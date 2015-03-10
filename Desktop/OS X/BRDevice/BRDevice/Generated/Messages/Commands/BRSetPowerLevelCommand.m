//
//  BRSetPowerLevelCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetPowerLevelCommand.h"
#import "BRMessage_Private.h"


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
