//
//  BRConfigureSignalStrengthEventsCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureSignalStrengthEventsCommand.h"
#import "BRMessage_Private.h"




@implementation BRConfigureSignalStrengthEventsCommand

#pragma mark - Public

+ (BRConfigureSignalStrengthEventsCommand *)commandWithConnectionId:(uint8_t)connectionId enable:(BOOL)enable dononly:(BOOL)dononly trend:(BOOL)trend reportRssiAudio:(BOOL)reportRssiAudio reportNearFarAudio:(BOOL)reportNearFarAudio reportNearFarToBase:(BOOL)reportNearFarToBase sensitivity:(uint8_t)sensitivity nearThreshold:(uint8_t)nearThreshold maxTimeout:(int16_t)maxTimeout
{
	BRConfigureSignalStrengthEventsCommand *instance = [[BRConfigureSignalStrengthEventsCommand alloc] init];
	instance.connectionId = connectionId;
	instance.enable = enable;
	instance.dononly = dononly;
	instance.trend = trend;
	instance.reportRssiAudio = reportRssiAudio;
	instance.reportNearFarAudio = reportNearFarAudio;
	instance.reportNearFarToBase = reportNearFarToBase;
	instance.sensitivity = sensitivity;
	instance.nearThreshold = nearThreshold;
	instance.maxTimeout = maxTimeout;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_SIGNAL_STRENGTH_EVENTS;
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
    return [NSString stringWithFormat:@"<BRConfigureSignalStrengthEventsCommand %p> connectionId=0x%02X, enable=%@, dononly=%@, trend=%@, reportRssiAudio=%@, reportNearFarAudio=%@, reportNearFarToBase=%@, sensitivity=0x%02X, nearThreshold=0x%02X, maxTimeout=0x%04X",
            self, self.connectionId, (self.enable ? @"YES" : @"NO"), (self.dononly ? @"YES" : @"NO"), (self.trend ? @"YES" : @"NO"), (self.reportRssiAudio ? @"YES" : @"NO"), (self.reportNearFarAudio ? @"YES" : @"NO"), (self.reportNearFarToBase ? @"YES" : @"NO"), self.sensitivity, self.nearThreshold, self.maxTimeout];
}

@end
