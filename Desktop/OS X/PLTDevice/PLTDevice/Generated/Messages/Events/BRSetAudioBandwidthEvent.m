//
//  BRSetAudioBandwidthEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetAudioBandwidthEvent.h"
#import "BRMessage_Private.h"




@interface BRSetAudioBandwidthEvent ()

@property(nonatomic,assign,readwrite) uint8_t interfaceType;
@property(nonatomic,assign,readwrite) uint8_t bandwidth;


@end


@implementation BRSetAudioBandwidthEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_AUDIO_BANDWIDTH_EVENT;
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
    return [NSString stringWithFormat:@"<BRSetAudioBandwidthEvent %p> interfaceType=0x%02X, bandwidth=0x%02X",
            self, self.interfaceType, self.bandwidth];
}

@end
