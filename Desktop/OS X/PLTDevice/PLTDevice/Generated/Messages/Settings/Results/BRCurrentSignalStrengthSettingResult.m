//
//  BRCurrentSignalStrengthSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCurrentSignalStrengthSettingResult.h"
#import "BRMessage_Private.h"




@interface BRCurrentSignalStrengthSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t connectionId;
@property(nonatomic,assign,readwrite) uint8_t strength;
@property(nonatomic,assign,readwrite) uint8_t nearFar;


@end


@implementation BRCurrentSignalStrengthSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CURRENT_SIGNAL_STRENGTH_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"strength", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"nearFar", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCurrentSignalStrengthSettingResult %p> connectionId=0x%02X, strength=0x%02X, nearFar=0x%02X",
            self, self.connectionId, self.strength, self.nearFar];
}

@end
