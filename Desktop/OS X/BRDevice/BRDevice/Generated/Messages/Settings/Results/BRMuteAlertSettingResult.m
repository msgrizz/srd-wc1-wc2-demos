//
//  BRMuteAlertSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRMuteAlertSettingResult.h"
#import "BRMessage_Private.h"


@interface BRMuteAlertSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t mode;
@property(nonatomic,assign,readwrite) uint8_t parameter;


@end


@implementation BRMuteAlertSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MUTE_ALERT_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"mode", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"parameter", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMuteAlertSettingResult %p> mode=0x%02X, parameter=0x%02X",
            self, self.mode, self.parameter];
}

@end
