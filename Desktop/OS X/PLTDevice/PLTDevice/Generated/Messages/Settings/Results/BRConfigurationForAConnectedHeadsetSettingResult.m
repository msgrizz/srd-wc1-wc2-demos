//
//  BRConfigurationForAConnectedHeadsetSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigurationForAConnectedHeadsetSettingResult.h"
#import "BRMessage_Private.h"




@interface BRConfigurationForAConnectedHeadsetSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t configuration;


@end


@implementation BRConfigurationForAConnectedHeadsetSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"configuration", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigurationForAConnectedHeadsetSettingResult %p> configuration=0x%02X",
            self, self.configuration];
}

@end
