//
//  BRConversationDynamicsReportingEnableCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONVERSATION_DYNAMICS_REPORTING_ENABLE 0x0F0D



@interface BRConversationDynamicsReportingEnableCommand : BRCommand

+ (BRConversationDynamicsReportingEnableCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
