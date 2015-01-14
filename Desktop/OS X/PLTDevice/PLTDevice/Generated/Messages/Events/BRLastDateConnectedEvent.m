//
//  BRLastDateConnectedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLastDateConnectedEvent.h"
#import "BRMessage_Private.h"


@interface BRLastDateConnectedEvent ()

@property(nonatomic,assign,readwrite) uint16_t month;
@property(nonatomic,assign,readwrite) uint16_t day;
@property(nonatomic,assign,readwrite) uint32_t year;


@end


@implementation BRLastDateConnectedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LAST_DATE_CONNECTED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"month", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"day", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"year", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRLastDateConnectedEvent %p> month=0x%04X, day=0x%04X, year=0x%08X",
            self, self.month, self.day, self.year];
}

@end
