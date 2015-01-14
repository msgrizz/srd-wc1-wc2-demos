//
//  BRDeviceStatusSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceStatusSettingResult.h"
#import "BRMessage_Private.h"


@interface BRDeviceStatusSettingResult ()

@property(nonatomic,strong,readwrite) NSData * deviceStatusData;


@end


@implementation BRDeviceStatusSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DEVICE_STATUS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"deviceStatusData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceStatusSettingResult %p> deviceStatusData=%@",
            self, self.deviceStatusData];
}

@end
