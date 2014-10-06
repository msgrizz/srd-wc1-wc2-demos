//
//  BRAutoMuteCallSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAutoMuteCallSettingResult.h"
#import "BRMessage_Private.h"




@interface BRAutoMuteCallSettingResult ()

@property(nonatomic,assign,readwrite) BOOL autoMuteCall;


@end


@implementation BRAutoMuteCallSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUTOMUTE_CALL_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoMuteCall", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAutoMuteCallSettingResult %p> autoMuteCall=%@",
            self, (self.autoMuteCall ? @"YES" : @"NO")];
}

@end
