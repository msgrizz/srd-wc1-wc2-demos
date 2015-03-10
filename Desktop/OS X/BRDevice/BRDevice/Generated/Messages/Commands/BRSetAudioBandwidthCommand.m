//
//  BRSetAudioBandwidthCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetAudioBandwidthCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetAudioBandwidthCommand

#pragma mark - Public

+ (BRSetAudioBandwidthCommand *)commandWithInterfaceType:(uint8_t)interfaceType bandwidth:(uint8_t)bandwidth
{
	BRSetAudioBandwidthCommand *instance = [[BRSetAudioBandwidthCommand alloc] init];
	instance.interfaceType = interfaceType;
	instance.bandwidth = bandwidth;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_AUDIO_BANDWIDTH;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"interfaceType", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"bandwidth", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetAudioBandwidthCommand %p> interfaceType=0x%02X, bandwidth=0x%02X",
            self, self.interfaceType, self.bandwidth];
}

@end
