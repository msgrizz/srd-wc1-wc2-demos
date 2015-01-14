//
//  BRSetRingtoneCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_RINGTONE 0x0F02



@interface BRSetRingtoneCommand : BRCommand

+ (BRSetRingtoneCommand *)commandWithInterfaceType:(uint8_t)interfaceType ringTone:(uint8_t)ringTone;

@property(nonatomic,assign) uint8_t interfaceType;
@property(nonatomic,assign) uint8_t ringTone;


@end
