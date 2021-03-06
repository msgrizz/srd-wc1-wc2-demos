//
//  BRMicrophoneMuteStateSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRMicrophoneMuteStateSettingResult.h"
#import "BRMessage_Private.h"


@interface BRMicrophoneMuteStateSettingResult ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRMicrophoneMuteStateSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MICROPHONE_MUTE_STATE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"state", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMicrophoneMuteStateSettingResult %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
