//
//  BRSpeakerVolumeEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSpeakerVolumeEvent.h"
#import "BRMessage_Private.h"


@interface BRSpeakerVolumeEvent ()

@property(nonatomic,assign,readwrite) uint8_t volumeValueType;
@property(nonatomic,assign,readwrite) int16_t volume;


@end


@implementation BRSpeakerVolumeEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SPEAKER_VOLUME_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"volumeValueType", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"volume", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSpeakerVolumeEvent %p> volumeValueType=0x%02X, volume=0x%04X",
            self, self.volumeValueType, self.volume];
}

@end
