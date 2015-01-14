//
//  BRCustomDeviceStatusSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCustomDeviceStatusSettingResult.h"
#import "BRMessage_Private.h"


@interface BRCustomDeviceStatusSettingResult ()

@property(nonatomic,strong,readwrite) NSData * deviceCustomStatusData;


@end


@implementation BRCustomDeviceStatusSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CUSTOM_DEVICE_STATUS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"deviceCustomStatusData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCustomDeviceStatusSettingResult %p> deviceCustomStatusData=%@",
            self, self.deviceCustomStatusData];
}

@end
