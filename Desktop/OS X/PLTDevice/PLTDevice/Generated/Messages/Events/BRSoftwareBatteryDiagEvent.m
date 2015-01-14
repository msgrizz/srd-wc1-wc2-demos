//
//  BRSoftwareBatteryDiagEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSoftwareBatteryDiagEvent.h"
#import "BRMessage_Private.h"


@interface BRSoftwareBatteryDiagEvent ()

@property(nonatomic,strong,readwrite) NSData * softwareBatteryData;


@end


@implementation BRSoftwareBatteryDiagEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SOFTWARE_BATTERY_DIAG_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"softwareBatteryData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSoftwareBatteryDiagEvent %p> softwareBatteryData=%@",
            self, self.softwareBatteryData];
}

@end
