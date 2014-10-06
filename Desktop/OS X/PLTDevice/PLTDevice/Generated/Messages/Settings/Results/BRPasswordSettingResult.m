//
//  BRPasswordSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPasswordSettingResult.h"
#import "BRMessage_Private.h"




@interface BRPasswordSettingResult ()

@property(nonatomic,strong,readwrite) NSString * password;


@end


@implementation BRPasswordSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PASSWORD_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"password", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPasswordSettingResult %p> password=%@",
            self, self.password];
}

@end
