//
//  BRSetRingtoneVolumeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_RINGTONE_VOLUME 0x0F06



@interface BRSetRingtoneVolumeCommand : BRCommand

+ (BRSetRingtoneVolumeCommand *)commandWithInterfaceType:(uint8_t)interfaceType volume:(uint8_t)volume;

@property(nonatomic,assign) uint8_t interfaceType;
@property(nonatomic,assign) uint8_t volume;


@end
