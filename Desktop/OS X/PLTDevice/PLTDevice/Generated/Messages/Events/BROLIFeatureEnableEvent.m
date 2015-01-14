//
//  BROLIFeatureEnableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROLIFeatureEnableEvent.h"
#import "BRMessage_Private.h"


@interface BROLIFeatureEnableEvent ()

@property(nonatomic,assign,readwrite) uint8_t oLIenable;


@end


@implementation BROLIFeatureEnableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_OLI_FEATURE_ENABLE_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"oLIenable", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROLIFeatureEnableEvent %p> oLIenable=0x%02X",
            self, self.oLIenable];
}

@end
