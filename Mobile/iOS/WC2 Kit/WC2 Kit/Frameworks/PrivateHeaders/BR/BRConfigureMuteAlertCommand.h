//
//  BRConfigureMuteAlertCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_MUTE_ALERT 0x040A



@interface BRConfigureMuteAlertCommand : BRCommand

+ (BRConfigureMuteAlertCommand *)commandWithMode:(uint8_t)mode parameter:(uint8_t)parameter;

@property(nonatomic,assign) uint8_t mode;
@property(nonatomic,assign) uint8_t parameter;


@end
