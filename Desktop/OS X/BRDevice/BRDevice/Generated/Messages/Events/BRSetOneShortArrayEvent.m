//
//  BRSetOneShortArrayEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneShortArrayEvent.h"
#import "BRMessage_Private.h"


@interface BRSetOneShortArrayEvent ()

@property(nonatomic,strong,readwrite) NSData * value;


@end


@implementation BRSetOneShortArrayEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_SHORT_ARRAY_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneShortArrayEvent %p> value=%@",
            self, self.value];
}

@end
