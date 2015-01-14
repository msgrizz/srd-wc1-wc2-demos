//
//  BRStopAutoConnectOnDockSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRStopAutoConnectOnDockSettingResult.h"
#import "BRMessage_Private.h"


@interface BRStopAutoConnectOnDockSettingResult ()

@property(nonatomic,assign,readwrite) BOOL stopAutoConnect;


@end


@implementation BRStopAutoConnectOnDockSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_STOP_AUTOCONNECT_ON_DOCK_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"stopAutoConnect", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRStopAutoConnectOnDockSettingResult %p> stopAutoConnect=%@",
            self, (self.stopAutoConnect ? @"YES" : @"NO")];
}

@end
