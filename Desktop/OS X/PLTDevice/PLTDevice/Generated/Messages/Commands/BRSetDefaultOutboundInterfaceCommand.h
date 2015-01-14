//
//  BRSetDefaultOutboundInterfaceCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_DEFAULT_OUTBOUND_INTERFACE 0x0F08

#define BRDefinedValue_SetDefaultOutboundInterfaceCommand_InterfaceType_InterfacePstn 0
#define BRDefinedValue_SetDefaultOutboundInterfaceCommand_InterfaceType_InterfaceUsb 1
#define BRDefinedValue_SetDefaultOutboundInterfaceCommand_InterfaceType_InterfaceMobile 2


@interface BRSetDefaultOutboundInterfaceCommand : BRCommand

+ (BRSetDefaultOutboundInterfaceCommand *)commandWithInterfaceType:(uint8_t)interfaceType;

@property(nonatomic,assign) uint8_t interfaceType;


@end
