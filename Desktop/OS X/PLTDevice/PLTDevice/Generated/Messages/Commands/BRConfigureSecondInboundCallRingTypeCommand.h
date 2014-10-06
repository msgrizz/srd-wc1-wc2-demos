//
//  BRConfigureSecondInboundCallRingTypeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE 0x0404

extern const uint8_t ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeNone;
extern const uint8_t ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeOnce;
extern const uint8_t ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeContinuous;


@interface BRConfigureSecondInboundCallRingTypeCommand : BRCommand

+ (BRConfigureSecondInboundCallRingTypeCommand *)commandWithRingType:(uint8_t)ringType;

@property(nonatomic,assign) uint8_t ringType;


@end
