//
//  BRSetOneShortEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneShortEvent.h"
#import "BRMessage_Private.h"


@interface BRSetOneShortEvent ()

@property(nonatomic,assign,readwrite) int16_t value;


@end


@implementation BRSetOneShortEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_SHORT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneShortEvent %p> value=0x%04X",
            self, self.value];
}

@end
