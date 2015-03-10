//
//  BRSetDSPParametersCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_DSP_PARAMETERS 0x0F42



@interface BRSetDSPParametersCommand : BRCommand

+ (BRSetDSPParametersCommand *)commandWithCodec:(uint8_t)codec storeIsVolatile:(BOOL)storeIsVolatile parameterIndex:(int16_t)parameterIndex payload:(NSData *)payload;

@property(nonatomic,assign) uint8_t codec;
@property(nonatomic,assign) BOOL storeIsVolatile;
@property(nonatomic,assign) int16_t parameterIndex;
@property(nonatomic,strong) NSData * payload;


@end
