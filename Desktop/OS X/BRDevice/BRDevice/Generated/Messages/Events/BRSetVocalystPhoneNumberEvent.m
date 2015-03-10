//
//  BRSetVocalystPhoneNumberEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetVocalystPhoneNumberEvent.h"
#import "BRMessage_Private.h"


@interface BRSetVocalystPhoneNumberEvent ()

@property(nonatomic,strong,readwrite) NSString * vocalystPhoneNumber;


@end


@implementation BRSetVocalystPhoneNumberEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_VOCALYST_PHONE_NUMBER_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"vocalystPhoneNumber", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetVocalystPhoneNumberEvent %p> vocalystPhoneNumber=%@",
            self, self.vocalystPhoneNumber];
}

@end
