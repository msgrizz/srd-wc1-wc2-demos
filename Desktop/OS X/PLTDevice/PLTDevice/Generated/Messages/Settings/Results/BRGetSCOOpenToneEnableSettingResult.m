//
//  BRGetSCOOpenToneEnableSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetSCOOpenToneEnableSettingResult.h"
#import "BRMessage_Private.h"




@interface BRGetSCOOpenToneEnableSettingResult ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRGetSCOOpenToneEnableSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_SCO_OPEN_TONE_ENABLE_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRGetSCOOpenToneEnableSettingResult %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
