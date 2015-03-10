//
//  BRTextToSpeechTestCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TEXT_TO_SPEECH_TEST 0x100C



@interface BRTextToSpeechTestCommand : BRCommand

+ (BRTextToSpeechTestCommand *)commandWithText:(NSString *)text;

@property(nonatomic,strong) NSString * text;


@end
