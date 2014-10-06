//
//  BRConfigureCurrentLanguageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_CURRENT_LANGUAGE 0x0E1A

extern const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdEnglishUS;
extern const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdEnglishUK;
extern const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdJapanese;
extern const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdPortugueseBrazil;
extern const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdPortuguesePortugal;
extern const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdFrenchFrance;
extern const uint16_t ConfigureCurrentLanguageCommand_LanguageId_LanguageIdSpanishMexico;


@interface BRConfigureCurrentLanguageCommand : BRCommand

+ (BRConfigureCurrentLanguageCommand *)commandWithLanguageId:(uint16_t)languageId;

@property(nonatomic,assign) uint16_t languageId;


@end
