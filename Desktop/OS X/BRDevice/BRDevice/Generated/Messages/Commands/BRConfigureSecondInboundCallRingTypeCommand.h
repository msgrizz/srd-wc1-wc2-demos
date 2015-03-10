//
//  BRConfigureSecondInboundCallRingTypeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE 0x0404

#define BRDefinedValue_ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeNone 0
#define BRDefinedValue_ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeOnce 1
#define BRDefinedValue_ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeContinuous 2


@interface BRConfigureSecondInboundCallRingTypeCommand : BRCommand

+ (BRConfigureSecondInboundCallRingTypeCommand *)commandWithRingType:(uint8_t)ringType;

@property(nonatomic,assign) uint8_t ringType;


@end
