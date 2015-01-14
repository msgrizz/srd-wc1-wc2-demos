//
//  BRA2DPIsEnabledSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRA2DPIsEnabledSettingResult.h"
#import "BRMessage_Private.h"


@interface BRA2DPIsEnabledSettingResult ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRA2DPIsEnabledSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_A2DP_IS_ENABLED_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRA2DPIsEnabledSettingResult %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
