//
//  BRCurrentSignalStrengthSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCurrentSignalStrengthSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRCurrentSignalStrengthSettingRequest

#pragma BRSettingRequest

+ (BRCurrentSignalStrengthSettingRequest *)requestWithConnectionId:(uint8_t)connectionId
{
	BRCurrentSignalStrengthSettingRequest *instance = [[BRCurrentSignalStrengthSettingRequest alloc] init];
	instance.connectionId = connectionId;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CURRENT_SIGNAL_STRENGTH_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCurrentSignalStrengthSettingRequest %p> connectionId=0x%02X",
            self, self.connectionId];
}

@end
