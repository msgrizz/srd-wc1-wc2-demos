//
//  BRSetIntellistandAutoAnswerCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_INTELLISTAND_AUTOANSWER 0x0F1E



@interface BRSetIntellistandAutoAnswerCommand : BRCommand

+ (BRSetIntellistandAutoAnswerCommand *)commandWithIntellistand:(BOOL)intellistand;

@property(nonatomic,assign) BOOL intellistand;


@end
