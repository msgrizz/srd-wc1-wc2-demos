//
//  BRSetToneControlCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TONE_CONTROL 0x0F1A

extern const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMaxBass;
extern const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMidBass;
extern const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMinBass;
extern const uint8_t SetToneControlCommand_ToneLevel_ToneLevelNoBoost;
extern const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMinTreble;
extern const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMidTreble;
extern const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMaxTreble;


@interface BRSetToneControlCommand : BRCommand

+ (BRSetToneControlCommand *)commandWithInterfaceType:(uint8_t)interfaceType toneLevel:(uint8_t)toneLevel;

@property(nonatomic,assign) uint8_t interfaceType;
@property(nonatomic,assign) uint8_t toneLevel;


@end
