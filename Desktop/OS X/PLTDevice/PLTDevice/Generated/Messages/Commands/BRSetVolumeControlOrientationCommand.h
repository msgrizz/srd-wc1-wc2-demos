//
//  BRSetVolumeControlOrientationCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_VOLUME_CONTROL_ORIENTATION 0x0F2E

#define BRDefinedValue_SetVolumeControlOrientationCommand_Orientation_right 0
#define BRDefinedValue_SetVolumeControlOrientationCommand_Orientation_left 1


@interface BRSetVolumeControlOrientationCommand : BRCommand

+ (BRSetVolumeControlOrientationCommand *)commandWithOrientation:(uint8_t)orientation;

@property(nonatomic,assign) uint8_t orientation;


@end
