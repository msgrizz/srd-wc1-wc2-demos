//
//  BRSpokenLanguageSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSpokenLanguageSettingResult.h"
#import "BRMessage_Private.h"




@interface BRSpokenLanguageSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t languageId;


@end


@implementation BRSpokenLanguageSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SPOKEN_LANGUAGE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"languageId", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSpokenLanguageSettingResult %p> languageId=0x%04X",
            self, self.languageId];
}

@end
