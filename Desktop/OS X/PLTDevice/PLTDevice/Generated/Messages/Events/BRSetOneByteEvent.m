//
//  BRSetOneByteEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOneByteEvent.h"
#import "BRMessage_Private.h"




@interface BRSetOneByteEvent ()

@property(nonatomic,assign,readwrite) uint8_t value;


@end


@implementation BRSetOneByteEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_BYTE_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneByteEvent %p> value=0x%02X",
            self, self.value];
}

@end
