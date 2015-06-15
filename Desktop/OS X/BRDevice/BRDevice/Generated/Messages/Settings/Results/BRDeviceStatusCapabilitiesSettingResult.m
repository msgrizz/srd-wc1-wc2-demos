//
//  BRDeviceStatusCapabilitiesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRDeviceStatusCapabilitiesSettingResult.h"
#import "BRMessage_Private.h"


@interface BRDeviceStatusCapabilitiesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * supportedDeviceStatusIDs;


@end


@implementation BRDeviceStatusCapabilitiesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DEVICE_STATUS_CAPABILITIES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"supportedDeviceStatusIDs", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceStatusCapabilitiesSettingResult %p> supportedDeviceStatusIDs=%@",
            self, self.supportedDeviceStatusIDs];
}

@end