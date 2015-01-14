//
//  BRGetMuteOffVPSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetMuteOffVPSettingResult.h"
#import "BRMessage_Private.h"


@interface BRGetMuteOffVPSettingResult ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRGetMuteOffVPSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_MUTE_OFF_VP_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetMuteOffVPSettingResult %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
