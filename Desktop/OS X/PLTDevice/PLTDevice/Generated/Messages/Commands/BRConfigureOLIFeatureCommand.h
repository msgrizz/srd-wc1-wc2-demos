//
//  BRConfigureOLIFeatureCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_OLI_FEATURE 0x0409

extern const uint8_t ConfigureOLIFeatureCommand_OLIenable_enable;
extern const uint8_t ConfigureOLIFeatureCommand_OLIenable_disable;


@interface BRConfigureOLIFeatureCommand : BRCommand

+ (BRConfigureOLIFeatureCommand *)commandWithOLIenable:(uint8_t)oLIenable;

@property(nonatomic,assign) uint8_t oLIenable;


@end
