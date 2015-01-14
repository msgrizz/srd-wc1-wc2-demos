//
//  BRLastDateConnectedCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLastDateConnectedCommand.h"
#import "BRMessage_Private.h"


@implementation BRLastDateConnectedCommand

#pragma mark - Public

+ (BRLastDateConnectedCommand *)commandWithMonth:(uint16_t)month day:(uint16_t)day year:(uint32_t)year
{
	BRLastDateConnectedCommand *instance = [[BRLastDateConnectedCommand alloc] init];
	instance.month = month;
	instance.day = day;
	instance.year = year;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LAST_DATE_CONNECTED;
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
    return [NSString stringWithFormat:@"<BRLastDateConnectedCommand %p> month=0x%04X, day=0x%04X, year=0x%08X",
            self, self.month, self.day, self.year];
}

@end
