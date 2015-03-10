//
//  BRTattooSerialNumberSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTattooSerialNumberSettingResult.h"
#import "BRMessage_Private.h"


@interface BRTattooSerialNumberSettingResult ()

@property(nonatomic,strong,readwrite) NSData * serialNumber;


@end


@implementation BRTattooSerialNumberSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TATTOO_SERIAL_NUMBER_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRTattooSerialNumberSettingResult %p> serialNumber=%@",
            self, self.serialNumber];
}

@end
