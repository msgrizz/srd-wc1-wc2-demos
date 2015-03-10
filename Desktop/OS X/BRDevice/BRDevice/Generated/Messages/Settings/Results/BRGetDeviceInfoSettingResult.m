//
//  BRGetDeviceInfoSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGetDeviceInfoSettingResult.h"
#import "BRMessage_Private.h"


@interface BRGetDeviceInfoSettingResult ()

@property(nonatomic,strong,readwrite) NSData * majorHardwareVersion;
@property(nonatomic,strong,readwrite) NSData * minorHardwareVersion;
@property(nonatomic,strong,readwrite) NSData * majorFirmwareVersion;
@property(nonatomic,strong,readwrite) NSData * minorFirmwareVersion;
@property(nonatomic,strong,readwrite) NSData * supportedServices;


@end


@implementation BRGetDeviceInfoSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_DEVICE_INFO_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"majorHardwareVersion", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"minorHardwareVersion", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"majorFirmwareVersion", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"minorFirmwareVersion", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"supportedServices", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetDeviceInfoSettingResult %p> majorHardwareVersion=%@, minorHardwareVersion=%@, majorFirmwareVersion=%@, minorFirmwareVersion=%@, supportedServices=%@",
            self, self.majorHardwareVersion, self.minorHardwareVersion, self.majorFirmwareVersion, self.minorFirmwareVersion, self.supportedServices];
}

@end
