//
//  BRHeadsetAvailableCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_HEADSET_AVAILABLE 0x0E09



@interface BRHeadsetAvailableCommand : BRCommand

+ (BRHeadsetAvailableCommand *)commandWithState:(BOOL)state;

@property(nonatomic,assign) BOOL state;


@end
