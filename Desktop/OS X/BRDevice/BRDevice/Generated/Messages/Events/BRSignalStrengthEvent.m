//
//  BRSignalStrengthEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSignalStrengthEvent.h"
#import "BRMessage_Private.h"


@interface BRSignalStrengthEvent ()

@property(nonatomic,assign,readwrite) uint8_t connectionId;
@property(nonatomic,assign,readwrite) uint8_t strength;
@property(nonatomic,assign,readwrite) uint8_t nearFar;


@end


@implementation BRSignalStrengthEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SIGNAL_STRENGTH_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"strength", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"nearFar", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSignalStrengthEvent %p> connectionId=0x%02X, strength=0x%02X, nearFar=0x%02X",
            self, self.connectionId, self.strength, self.nearFar];
}

@end
