//
//  BRSetToneControlCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TONE_CONTROL 0x0F1A

#define BRDefinedValue_SetToneControlCommand_ToneLevel_ToneLevelMaxBass 0
#define BRDefinedValue_SetToneControlCommand_ToneLevel_ToneLevelMidBass 1
#define BRDefinedValue_SetToneControlCommand_ToneLevel_ToneLevelMinBass 2
#define BRDefinedValue_SetToneControlCommand_ToneLevel_ToneLevelNoBoost 3
#define BRDefinedValue_SetToneControlCommand_ToneLevel_ToneLevelMinTreble 4
#define BRDefinedValue_SetToneControlCommand_ToneLevel_ToneLevelMidTreble 5
#define BRDefinedValue_SetToneControlCommand_ToneLevel_ToneLevelMaxTreble 6


@interface BRSetToneControlCommand : BRCommand

+ (BRSetToneControlCommand *)commandWithInterfaceType:(uint8_t)interfaceType toneLevel:(uint8_t)toneLevel;

@property(nonatomic,assign) uint8_t interfaceType;
@property(nonatomic,assign) uint8_t toneLevel;


@end
