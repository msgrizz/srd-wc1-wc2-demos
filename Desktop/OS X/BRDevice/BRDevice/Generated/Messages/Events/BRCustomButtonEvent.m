//
//  BRCustomButtonEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCustomButtonEvent.h"
#import "BRMessage_Private.h"


@interface BRCustomButtonEvent ()

@property(nonatomic,assign,readwrite) uint8_t index;


@end


@implementation BRCustomButtonEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CUSTOM_BUTTON_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"index", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCustomButtonEvent %p> index=0x%02X",
            self, self.index];
}

@end
