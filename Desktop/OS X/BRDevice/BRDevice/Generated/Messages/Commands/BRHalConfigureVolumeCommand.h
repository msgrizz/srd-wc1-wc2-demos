//
//  BRHalConfigureVolumeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_HAL_CONFIGURE_VOLUME 0x1102



@interface BRHalConfigureVolumeCommand : BRCommand

+ (BRHalConfigureVolumeCommand *)commandWithScenario:(uint16_t)scenario volumes:(NSData *)volumes;

@property(nonatomic,assign) uint16_t scenario;
@property(nonatomic,strong) NSData * volumes;


@end
