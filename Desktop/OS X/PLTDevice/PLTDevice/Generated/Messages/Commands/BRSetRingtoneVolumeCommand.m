//
//  BRSetRingtoneVolumeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetRingtoneVolumeCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetRingtoneVolumeCommand

#pragma mark - Public

+ (BRSetRingtoneVolumeCommand *)commandWithInterfaceType:(uint8_t)interfaceType volume:(uint8_t)volume
{
	BRSetRingtoneVolumeCommand *instance = [[BRSetRingtoneVolumeCommand alloc] init];
	instance.interfaceType = interfaceType;
	instance.volume = volume;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_RINGTONE_VOLUME;
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
    return [NSString stringWithFormat:@"<BRSetRingtoneVolumeCommand %p> interfaceType=0x%02X, volume=0x%02X",
            self, self.interfaceType, self.volume];
}

@end
