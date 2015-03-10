//
//  BRSetOneLongEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneLongEvent.h"
#import "BRMessage_Private.h"


@interface BRSetOneLongEvent ()

@property(nonatomic,assign,readwrite) int32_t value;


@end


@implementation BRSetOneLongEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_LONG_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeLong)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneLongEvent %p> value=0x%08X",
            self, self.value];
}

@end
