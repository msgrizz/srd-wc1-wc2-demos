//
//  BRTxPowerReportingSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTxPowerReportingSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRTxPowerReportingSettingRequest

#pragma BRSettingRequest

+ (BRTxPowerReportingSettingRequest *)requestWithConnectionId:(uint8_t)connectionId
{
	BRTxPowerReportingSettingRequest *instance = [[BRTxPowerReportingSettingRequest alloc] init];
	instance.connectionId = connectionId;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TXPOWER_REPORTING_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRTxPowerReportingSettingRequest %p> connectionId=0x%02X",
            self, self.connectionId];
}

@end
