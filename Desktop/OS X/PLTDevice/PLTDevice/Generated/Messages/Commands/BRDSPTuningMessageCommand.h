//
//  BRDSPTuningMessageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_DSP_TUNING_MESSAGE 0x0801



@interface BRDSPTuningMessageCommand : BRCommand

+ (BRDSPTuningMessageCommand *)commandWithData:(NSData *)data;

@property(nonatomic,strong) NSData * data;


@end
