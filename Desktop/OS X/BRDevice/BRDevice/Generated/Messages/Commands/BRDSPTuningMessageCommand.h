//
//  BRDSPTuningMessageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_DSP_TUNING_MESSAGE 0x0801



@interface BRDSPTuningMessageCommand : BRCommand

+ (BRDSPTuningMessageCommand *)commandWithData:(NSData *)data;

@property(nonatomic,strong) NSData * data;


@end
