//
//  BRSetOneStringEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOneStringEvent.h"
#import "BRMessage_Private.h"


@interface BRSetOneStringEvent ()

@property(nonatomic,strong,readwrite) NSString * value;


@end


@implementation BRSetOneStringEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_STRING_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneStringEvent %p> value=%@",
            self, self.value];
}

@end
