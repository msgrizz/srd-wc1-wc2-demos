//
//  BRStartGeneratingEventsCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_START_GENERATING_EVENTS 0x0001



@interface BRStartGeneratingEventsCommand : BRCommand

+ (BRStartGeneratingEventsCommand *)commandWithCount:(int32_t)count delay:(int32_t)delay dataLength:(int32_t)dataLength;

@property(nonatomic,assign) int32_t count;
@property(nonatomic,assign) int32_t delay;
@property(nonatomic,assign) int32_t dataLength;


@end
