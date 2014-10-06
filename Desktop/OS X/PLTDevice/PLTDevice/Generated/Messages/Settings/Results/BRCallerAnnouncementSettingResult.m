//
//  BRCallerAnnouncementSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCallerAnnouncementSettingResult.h"
#import "BRMessage_Private.h"




@interface BRCallerAnnouncementSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t value;


@end


@implementation BRCallerAnnouncementSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CALLER_ANNOUNCEMENT_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCallerAnnouncementSettingResult %p> value=0x%02X",
            self, self.value];
}

@end
