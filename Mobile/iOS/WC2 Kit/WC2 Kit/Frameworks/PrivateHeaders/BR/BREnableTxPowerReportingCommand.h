//
//  BREnableTxPowerReportingCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_ENABLE_TXPOWER_REPORTING 0x0810



@interface BREnableTxPowerReportingCommand : BRCommand

+ (BREnableTxPowerReportingCommand *)commandWithConnectionId:(uint8_t)connectionId enable:(BOOL)enable;

@property(nonatomic,assign) uint8_t connectionId;
@property(nonatomic,assign) BOOL enable;


@end
