//
//  BRTxPowerReportingSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTxPowerReportingSettingResult.h"
#import "BRMessage_Private.h"


@interface BRTxPowerReportingSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t connectionId;
@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRTxPowerReportingSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TXPOWER_REPORTING_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTxPowerReportingSettingResult %p> connectionId=0x%02X, enable=%@",
            self, self.connectionId, (self.enable ? @"YES" : @"NO")];
}

@end