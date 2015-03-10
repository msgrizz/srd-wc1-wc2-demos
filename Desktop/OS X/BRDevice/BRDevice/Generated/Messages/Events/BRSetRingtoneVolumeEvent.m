//
//  BRSetRingtoneVolumeEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetRingtoneVolumeEvent.h"
#import "BRMessage_Private.h"


@interface BRSetRingtoneVolumeEvent ()

@property(nonatomic,assign,readwrite) uint8_t interfaceType;
@property(nonatomic,assign,readwrite) uint8_t volume;


@end


@implementation BRSetRingtoneVolumeEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_RINGTONE_VOLUME_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"interfaceType", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"volume", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetRingtoneVolumeEvent %p> interfaceType=0x%02X, volume=0x%02X",
            self, self.interfaceType, self.volume];
}

@end
