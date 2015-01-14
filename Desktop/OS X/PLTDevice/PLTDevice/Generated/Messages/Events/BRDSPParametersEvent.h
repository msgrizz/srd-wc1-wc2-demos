//
//  BRDSPParametersEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_DSP_PARAMETERS_EVENT 0x0F42



@interface BRDSPParametersEvent : BREvent

@property(nonatomic,readonly) uint8_t codec;
@property(nonatomic,readonly) BOOL storeIsVolatile;
@property(nonatomic,readonly) int16_t parameterIndex;
@property(nonatomic,readonly) NSData * payload;


@end
