//
//  BRSendDeviceDetachedEventCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SEND_DEVICE_DETACHED_EVENT 0x0105



@interface BRSendDeviceDetachedEventCommand : BRCommand

+ (BRSendDeviceDetachedEventCommand *)commandWithMilliseconds:(int16_t)milliseconds;

@property(nonatomic,assign) int16_t milliseconds;


@end
