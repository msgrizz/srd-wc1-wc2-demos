//
//  BRLEDStatusGenericEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLEDStatusGenericEvent.h"
#import "BRMessage_Private.h"




@interface BRLEDStatusGenericEvent ()

@property(nonatomic,strong,readwrite) NSData * iD;
@property(nonatomic,strong,readwrite) NSData * color;
@property(nonatomic,strong,readwrite) NSData * state;


@end


@implementation BRLEDStatusGenericEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LED_STATUS_GENERIC_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"iD", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"color", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"state", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRLEDStatusGenericEvent %p> iD=%@, color=%@, state=%@",
            self, self.iD, self.color, self.state];
}

@end
