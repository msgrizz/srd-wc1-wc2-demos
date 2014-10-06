//
//  BRTimeUsedCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TIME_USED 0x0A0D



@interface BRTimeUsedCommand : BRCommand

+ (BRTimeUsedCommand *)commandWithTotalTime:(uint16_t)totalTime;

@property(nonatomic,assign) uint16_t totalTime;


@end
