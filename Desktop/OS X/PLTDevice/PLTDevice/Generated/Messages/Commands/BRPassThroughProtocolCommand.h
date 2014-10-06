//
//  BRPassThroughProtocolCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_PASS_THROUGH_PROTOCOL 0xFF0F

extern const uint16_t PassThroughProtocolCommand_ProtocolID_ProtocolAPDU;


@interface BRPassThroughProtocolCommand : BRCommand

+ (BRPassThroughProtocolCommand *)commandWithProtocolID:(uint16_t)protocolID data:(NSData *)data;

@property(nonatomic,assign) uint16_t protocolID;
@property(nonatomic,strong) NSData * data;


@end
