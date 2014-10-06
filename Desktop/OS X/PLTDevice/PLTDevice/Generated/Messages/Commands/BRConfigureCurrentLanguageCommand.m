//
//  BRConfigureCurrentLanguageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureCurrentLanguageCommand.h"
#import "BRMessage_Private.h"


const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdEnglishUS = 0x0409;
const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdEnglishUK = 0x0809;
const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdJapanese = 0x0411;
const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdPortugueseBrazil = 0x0416;
const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdPortuguesePortugal = 0x0816;
const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdFrenchFrance = 0x040C;
const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdSpanishMexico = 0x080A;


@implementation BRConfigureCurrentLanguageCommand

#pragma mark - Public

+ (BRConfigureCurrentLanguageCommand *)commandWithLanguageId:(uint16_t)languageId
{
	BRConfigureCurrentLanguageCommand *instance = [[BRConfigureCurrentLanguageCommand alloc] init];
	instance.languageId = languageId;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_CURRENT_LANGUAGE;
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
    return [NSString stringWithFormat:@"<BRConfigureCurrentLanguageCommand %p> languageId=0x%04X",
            self, self.languageId];
}

@end
