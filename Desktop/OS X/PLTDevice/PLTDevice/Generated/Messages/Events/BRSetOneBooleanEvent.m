//
//  BRSetOneBooleanEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOneBooleanEvent.h"
#import "BRMessage_Private.h"


@interface BRSetOneBooleanEvent ()

@property(nonatomic,assign,readwrite) BOOL value;


@end


@implementation BRSetOneBooleanEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_BOOLEAN_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneBooleanEvent %p> value=%@",
            self, (self.value ? @"YES" : @"NO")];
}

@end
