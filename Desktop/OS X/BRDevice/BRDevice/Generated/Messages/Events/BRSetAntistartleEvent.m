//
//  BRSetAntistartleEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetAntistartleEvent.h"
#import "BRMessage_Private.h"


@interface BRSetAntistartleEvent ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRSetAntistartleEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ANTISTARTLE_EVENT;
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
    return [NSString stringWithFormat:@"<BRSetAntistartleEvent %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
