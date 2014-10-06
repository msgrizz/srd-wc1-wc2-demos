//
//  BRSetIntellistandAutoAnswerCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_INTELLISTAND_AUTOANSWER 0x0F1E



@interface BRSetIntellistandAutoAnswerCommand : BRCommand

+ (BRSetIntellistandAutoAnswerCommand *)commandWithIntellistand:(BOOL)intellistand;

@property(nonatomic,assign) BOOL intellistand;


@end
