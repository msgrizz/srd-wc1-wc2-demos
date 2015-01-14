//
//  BRConfigureFindHeadsetLEDAlertCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_FIND_HEADSET_LED_ALERT 0x0808



@interface BRConfigureFindHeadsetLEDAlertCommand : BRCommand

+ (BRConfigureFindHeadsetLEDAlertCommand *)commandWithEnable:(BOOL)enable timeout:(uint8_t)timeout;

@property(nonatomic,assign) BOOL enable;
@property(nonatomic,assign) uint8_t timeout;


@end
