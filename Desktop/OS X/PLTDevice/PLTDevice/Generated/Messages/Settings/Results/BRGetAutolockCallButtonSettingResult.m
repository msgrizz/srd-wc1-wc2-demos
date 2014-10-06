//
//  BRGetAutolockCallButtonSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetAutolockCallButtonSettingResult.h"
#import "BRMessage_Private.h"




@interface BRGetAutolockCallButtonSettingResult ()

@property(nonatomic,assign,readwrite) BOOL autoLockCallButton;


@end


@implementation BRGetAutolockCallButtonSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_AUTOLOCK_CALL_BUTTON_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoLockCallButton", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetAutolockCallButtonSettingResult %p> autoLockCallButton=%@",
            self, (self.autoLockCallButton ? @"YES" : @"NO")];
}

@end
