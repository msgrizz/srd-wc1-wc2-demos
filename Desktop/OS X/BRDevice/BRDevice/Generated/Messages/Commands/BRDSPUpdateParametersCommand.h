//
//  BRDSPUpdateParametersCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_DSP_UPDATE_PARAMETERS 0x0F44



@interface BRDSPUpdateParametersCommand : BRCommand

+ (BRDSPUpdateParametersCommand *)commandWithCodec:(uint8_t)codec;

@property(nonatomic,assign) uint8_t codec;


@end
