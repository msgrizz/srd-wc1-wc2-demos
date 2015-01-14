//
//  BRAutoanswerOnDonCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_AUTOANSWER_ON_DON 0x0204



@interface BRAutoanswerOnDonCommand : BRCommand

+ (BRAutoanswerOnDonCommand *)commandWithAnswerOnDon:(BOOL)answerOnDon;

@property(nonatomic,assign) BOOL answerOnDon;


@end
