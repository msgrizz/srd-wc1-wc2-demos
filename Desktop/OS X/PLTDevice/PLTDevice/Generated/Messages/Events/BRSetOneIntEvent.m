//
//  BRSetOneIntEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOneIntEvent.h"
#import "BRMessage_Private.h"


@interface BRSetOneIntEvent ()

@property(nonatomic,assign,readwrite) int32_t value;


@end


@implementation BRSetOneIntEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_INT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneIntEvent %p> value=0x%08X",
            self, self.value];
}

@end
