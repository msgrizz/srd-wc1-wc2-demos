//
//  BRMobileVoiceCommandsSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMobileVoiceCommandsSettingResult.h"
#import "BRMessage_Private.h"




@interface BRMobileVoiceCommandsSettingResult ()

@property(nonatomic,assign,readwrite) BOOL mobileVoiceCommands;


@end


@implementation BRMobileVoiceCommandsSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MOBILE_VOICE_COMMANDS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"mobileVoiceCommands", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMobileVoiceCommandsSettingResult %p> mobileVoiceCommands=%@",
            self, (self.mobileVoiceCommands ? @"YES" : @"NO")];
}

@end
