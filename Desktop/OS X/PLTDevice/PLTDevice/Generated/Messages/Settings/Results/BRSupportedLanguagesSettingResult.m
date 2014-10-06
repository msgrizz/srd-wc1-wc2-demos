//
//  BRSupportedLanguagesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSupportedLanguagesSettingResult.h"
#import "BRMessage_Private.h"




@interface BRSupportedLanguagesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * languages;


@end


@implementation BRSupportedLanguagesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SUPPORTED_LANGUAGES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"languages", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSupportedLanguagesSettingResult %p> languages=%@",
            self, self.languages];
}

@end
