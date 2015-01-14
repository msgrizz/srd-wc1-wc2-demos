//
//  BRHardwareBatteryDiagEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHardwareBatteryDiagEvent.h"
#import "BRMessage_Private.h"


@interface BRHardwareBatteryDiagEvent ()

@property(nonatomic,strong,readwrite) NSData * hardwareBatteryData;


@end


@implementation BRHardwareBatteryDiagEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HARDWARE_BATTERY_DIAG_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"hardwareBatteryData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHardwareBatteryDiagEvent %p> hardwareBatteryData=%@",
            self, self.hardwareBatteryData];
}

@end
