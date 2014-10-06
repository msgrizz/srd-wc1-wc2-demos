//
//  BRHeadsetAvailableSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHeadsetAvailableSettingResult.h"
#import "BRMessage_Private.h"




@interface BRHeadsetAvailableSettingResult ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRHeadsetAvailableSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HEADSET_AVAILABLE_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRHeadsetAvailableSettingResult %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
