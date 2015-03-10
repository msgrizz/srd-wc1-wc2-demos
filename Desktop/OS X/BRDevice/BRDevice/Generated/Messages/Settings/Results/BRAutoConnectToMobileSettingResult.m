//
//  BRAutoConnectToMobileSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAutoConnectToMobileSettingResult.h"
#import "BRMessage_Private.h"


@interface BRAutoConnectToMobileSettingResult ()

@property(nonatomic,assign,readwrite) BOOL autoConnect;


@end


@implementation BRAutoConnectToMobileSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUTOCONNECT_TO_MOBILE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoConnect", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAutoConnectToMobileSettingResult %p> autoConnect=%@",
            self, (self.autoConnect ? @"YES" : @"NO")];
}

@end
