//
//  BRHalConfigureVolumeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_HAL_CONFIGURE_VOLUME 0x1102



@interface BRHalConfigureVolumeCommand : BRCommand

+ (BRHalConfigureVolumeCommand *)commandWithScenario:(uint16_t)scenario volumes:(NSData *)volumes;

@property(nonatomic,assign) uint16_t scenario;
@property(nonatomic,strong) NSData * volumes;


@end
