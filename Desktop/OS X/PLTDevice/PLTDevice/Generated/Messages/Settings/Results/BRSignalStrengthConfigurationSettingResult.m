//
//  BRSignalStrengthConfigurationSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSignalStrengthConfigurationSettingResult.h"
#import "BRMessage_Private.h"




@interface BRSignalStrengthConfigurationSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t connectionId;
@property(nonatomic,assign,readwrite) BOOL enable;
@property(nonatomic,assign,readwrite) BOOL dononly;
@property(nonatomic,assign,readwrite) BOOL trend;
@property(nonatomic,assign,readwrite) BOOL reportRssiAudio;
@property(nonatomic,assign,readwrite) BOOL reportNearFarAudio;
@property(nonatomic,assign,readwrite) BOOL reportNearFarToBase;
@property(nonatomic,assign,readwrite) uint8_t sensitivity;
@property(nonatomic,assign,readwrite) uint8_t nearThreshold;
@property(nonatomic,assign,readwrite) int16_t maxTimeout;


@end


@implementation BRSignalStrengthConfigurationSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SIGNAL_STRENGTH_CONFIGURATION_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"dononly", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"trend", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"reportRssiAudio", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"reportNearFarAudio", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"reportNearFarToBase", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"sensitivity", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"nearThreshold", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"maxTimeout", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSignalStrengthConfigurationSettingResult %p> connectionId=0x%02X, enable=%@, dononly=%@, trend=%@, reportRssiAudio=%@, reportNearFarAudio=%@, reportNearFarToBase=%@, sensitivity=0x%02X, nearThreshold=0x%02X, maxTimeout=0x%04X",
            self, self.connectionId, (self.enable ? @"YES" : @"NO"), (self.dononly ? @"YES" : @"NO"), (self.trend ? @"YES" : @"NO"), (self.reportRssiAudio ? @"YES" : @"NO"), (self.reportNearFarAudio ? @"YES" : @"NO"), (self.reportNearFarToBase ? @"YES" : @"NO"), self.sensitivity, self.nearThreshold, self.maxTimeout];
}

@end
