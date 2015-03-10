//
//  BRSetG616Event.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetG616Event.h"
#import "BRMessage_Private.h"


@interface BRSetG616Event ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRSetG616Event

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_G616_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetG616Event %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
