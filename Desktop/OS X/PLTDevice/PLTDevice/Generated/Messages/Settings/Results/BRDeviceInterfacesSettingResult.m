//
//  BRDeviceInterfacesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceInterfacesSettingResult.h"
#import "BRMessage_Private.h"


@interface BRDeviceInterfacesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * interfacesAndRingTones;


@end


@implementation BRDeviceInterfacesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DEVICE_INTERFACES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"interfacesAndRingTones", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceInterfacesSettingResult %p> interfacesAndRingTones=%@",
            self, self.interfacesAndRingTones];
}

@end
