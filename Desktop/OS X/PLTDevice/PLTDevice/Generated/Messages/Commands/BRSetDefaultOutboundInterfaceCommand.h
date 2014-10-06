//
//  BRSetDefaultOutboundInterfaceCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_DEFAULT_OUTBOUND_INTERFACE 0x0F08

extern const uint8_t SetDefaultOutboundInterfaceCommand_InterfaceType_InterfacePstn;
extern const uint8_t SetDefaultOutboundInterfaceCommand_InterfaceType_InterfaceUsb;
extern const uint8_t SetDefaultOutboundInterfaceCommand_InterfaceType_InterfaceMobile;


@interface BRSetDefaultOutboundInterfaceCommand : BRCommand

+ (BRSetDefaultOutboundInterfaceCommand *)commandWithInterfaceType:(uint8_t)interfaceType;

@property(nonatomic,assign) uint8_t interfaceType;


@end
