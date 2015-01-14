//
//  BRPassThroughProtocolCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_PASS_THROUGH_PROTOCOL 0xFF0F

#define BRDefinedValue_PassThroughProtocolCommand_Protocolid_ProtocolNone 0
#define BRDefinedValue_PassThroughProtocolCommand_Protocolid_ProtocolAPDU 1


@interface BRPassThroughProtocolCommand : BRCommand

+ (BRPassThroughProtocolCommand *)commandWithProtocolid:(uint16_t)protocolid messageData:(NSData *)messageData;

@property(nonatomic,assign) uint16_t protocolid;
@property(nonatomic,strong) NSData * messageData;


@end
