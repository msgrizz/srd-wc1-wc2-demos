//
//  BRHalConfigureEQCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_HAL_CONFIGURE_EQ 0x1104



@interface BRHalConfigureEQCommand : BRCommand

+ (BRHalConfigureEQCommand *)commandWithScenario:(uint16_t)scenario numberOfEQs:(uint16_t)numberOfEQs eQId:(uint8_t)eQId eQSettings:(NSData *)eQSettings;

@property(nonatomic,assign) uint16_t scenario;
@property(nonatomic,assign) uint16_t numberOfEQs;
@property(nonatomic,assign) uint8_t eQId;
@property(nonatomic,strong) NSData * eQSettings;


@end
