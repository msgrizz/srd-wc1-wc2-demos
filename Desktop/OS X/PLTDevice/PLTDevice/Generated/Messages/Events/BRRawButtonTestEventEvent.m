//
//  BRRawButtonTestEventEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRawButtonTestEventEvent.h"
#import "BRMessage_Private.h"


@interface BRRawButtonTestEventEvent ()

@property(nonatomic,assign,readwrite) int16_t button;


@end


@implementation BRRawButtonTestEventEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RAW_BUTTON_TEST_EVENT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"button", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRRawButtonTestEventEvent %p> button=0x%04X",
            self, self.button];
}

@end
