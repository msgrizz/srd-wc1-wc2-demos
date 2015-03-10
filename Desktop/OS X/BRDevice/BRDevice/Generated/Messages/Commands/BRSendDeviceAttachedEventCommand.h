//
//  BRSendDeviceAttachedEventCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SEND_DEVICE_ATTACHED_EVENT 0x0104



@interface BRSendDeviceAttachedEventCommand : BRCommand

+ (BRSendDeviceAttachedEventCommand *)commandWithMilliseconds:(int16_t)milliseconds;

@property(nonatomic,assign) int16_t milliseconds;


@end
