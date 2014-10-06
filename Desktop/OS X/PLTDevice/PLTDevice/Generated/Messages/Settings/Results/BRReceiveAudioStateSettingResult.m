//
//  BRReceiveAudioStateSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRReceiveAudioStateSettingResult.h"
#import "BRMessage_Private.h"




@interface BRReceiveAudioStateSettingResult ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRReceiveAudioStateSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RECEIVE_AUDIO_STATE_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRReceiveAudioStateSettingResult %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
