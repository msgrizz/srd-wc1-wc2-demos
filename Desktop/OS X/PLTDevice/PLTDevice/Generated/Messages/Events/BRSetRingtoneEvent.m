//
//  BRSetRingtoneEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetRingtoneEvent.h"
#import "BRMessage_Private.h"


@interface BRSetRingtoneEvent ()

@property(nonatomic,assign,readwrite) uint8_t interfaceType;
@property(nonatomic,assign,readwrite) uint8_t ringTone;


@end


@implementation BRSetRingtoneEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_RINGTONE_EVENT;
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
    return [NSString stringWithFormat:@"<BRSetRingtoneEvent %p> interfaceType=0x%02X, ringTone=0x%02X",
            self, self.interfaceType, self.ringTone];
}

@end
