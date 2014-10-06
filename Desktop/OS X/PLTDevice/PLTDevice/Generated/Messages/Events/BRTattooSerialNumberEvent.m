//
//  BRTattooSerialNumberEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTattooSerialNumberEvent.h"
#import "BRMessage_Private.h"




@interface BRTattooSerialNumberEvent ()

@property(nonatomic,strong,readwrite) NSData * serialNumber;


@end


@implementation BRTattooSerialNumberEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TATTOO_SERIAL_NUMBER_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serialNumber", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTattooSerialNumberEvent %p> serialNumber=%@",
            self, self.serialNumber];
}

@end
