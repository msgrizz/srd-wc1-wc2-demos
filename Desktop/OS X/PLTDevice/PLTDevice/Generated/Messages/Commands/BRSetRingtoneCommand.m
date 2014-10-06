//
//  BRSetRingtoneCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetRingtoneCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetRingtoneCommand

#pragma mark - Public

+ (BRSetRingtoneCommand *)commandWithInterfaceType:(uint8_t)interfaceType ringTone:(uint8_t)ringTone
{
	BRSetRingtoneCommand *instance = [[BRSetRingtoneCommand alloc] init];
	instance.interfaceType = interfaceType;
	instance.ringTone = ringTone;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_RINGTONE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"interfaceType", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"ringTone", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetRingtoneCommand %p> interfaceType=0x%02X, ringTone=0x%02X",
            self, self.interfaceType, self.ringTone];
}

@end
