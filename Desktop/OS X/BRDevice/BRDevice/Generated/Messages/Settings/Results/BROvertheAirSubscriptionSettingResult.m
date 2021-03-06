//
//  BROvertheAirSubscriptionSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BROvertheAirSubscriptionSettingResult.h"
#import "BRMessage_Private.h"


@interface BROvertheAirSubscriptionSettingResult ()

@property(nonatomic,assign,readwrite) BOOL otaEnabled;


@end


@implementation BROvertheAirSubscriptionSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_OVERTHEAIR_SUBSCRIPTION_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"otaEnabled", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROvertheAirSubscriptionSettingResult %p> otaEnabled=%@",
            self, (self.otaEnabled ? @"YES" : @"NO")];
}

@end
