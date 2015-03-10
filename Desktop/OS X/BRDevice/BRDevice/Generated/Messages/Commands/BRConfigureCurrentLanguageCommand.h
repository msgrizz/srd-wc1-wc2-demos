//
//  BRConfigureCurrentLanguageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_CURRENT_LANGUAGE 0x0E1A

#define BRDefinedValue_ConfigureCurrentLanguageCommand_LanguageId_LanguageIdEnglishUS 0x0409
#define BRDefinedValue_ConfigureCurrentLanguageCommand_LanguageId_LanguageIdEnglishUK 0x0809
#define BRDefinedValue_ConfigureCurrentLanguageCommand_LanguageId_LanguageIdJapanese 0x0411
#define BRDefinedValue_ConfigureCurrentLanguageCommand_LanguageId_LanguageIdPortugueseBrazil 0x0416
#define BRDefinedValue_ConfigureCurrentLanguageCommand_LanguageId_LanguageIdPortuguesePortugal 0x0816
#define BRDefinedValue_ConfigureCurrentLanguageCommand_LanguageId_LanguageIdFrenchFrance 0x040C
#define BRDefinedValue_ConfigureCurrentLanguageCommand_LanguageId_LanguageIdSpanishMexico 0x080A


@interface BRConfigureCurrentLanguageCommand : BRCommand

+ (BRConfigureCurrentLanguageCommand *)commandWithLanguageId:(uint16_t)languageId;

@property(nonatomic,assign) uint16_t languageId;


@end
