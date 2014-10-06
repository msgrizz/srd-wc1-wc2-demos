//
//  BRFirstDateUsedCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFirstDateUsedCommand.h"
#import "BRMessage_Private.h"




@implementation BRFirstDateUsedCommand

#pragma mark - Public

+ (BRFirstDateUsedCommand *)commandWithMonth:(uint16_t)month day:(uint16_t)day year:(uint32_t)year
{
	BRFirstDateUsedCommand *instance = [[BRFirstDateUsedCommand alloc] init];
	instance.month = month;
	instance.day = day;
	instance.year = year;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FIRST_DATE_USED;
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
    return [NSString stringWithFormat:@"<BRFirstDateUsedCommand %p> month=0x%04X, day=0x%04X, year=0x%08X",
            self, self.month, self.day, self.year];
}

@end
