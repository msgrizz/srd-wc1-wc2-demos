//
//  BRSingleNVRAMConfigurationReadSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSingleNVRAMConfigurationReadSettingResult.h"
#import "BRMessage_Private.h"


@interface BRSingleNVRAMConfigurationReadSettingResult ()

@property(nonatomic,strong,readwrite) NSData * nvramConfiguration;


@end


@implementation BRSingleNVRAMConfigurationReadSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SINGLE_NVRAM_CONFIGURATION_READ_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"nvramConfiguration", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSingleNVRAMConfigurationReadSettingResult %p> nvramConfiguration=%@",
            self, self.nvramConfiguration];
}

@end
