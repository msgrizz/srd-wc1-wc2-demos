//
//  BRConfigureVRCallRejectAndAnswerCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_VR_CALL_REJECT_AND_ANSWER 0x0A08



@interface BRConfigureVRCallRejectAndAnswerCommand : BRCommand

+ (BRConfigureVRCallRejectAndAnswerCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
