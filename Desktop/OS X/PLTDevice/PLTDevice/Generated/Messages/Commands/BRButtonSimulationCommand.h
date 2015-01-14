//
//  BRButtonSimulationCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_BUTTON_SIMULATION 0x1002

#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionSkp 0x00
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionMkp 0x01
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionLkp 0x02
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionVlkp 0x03
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionDkp 0x04
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionVvlkp 0x05
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionSlkp 0x06
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionPress 0x07
#define BRDefinedValue_ButtonSimulationCommand_ButtonAction_ButtonActionRelease 0x08


@interface BRButtonSimulationCommand : BRCommand

+ (BRButtonSimulationCommand *)commandWithButtonAction:(uint8_t)buttonAction buttonIDs:(NSData *)buttonIDs;

@property(nonatomic,assign) uint8_t buttonAction;
@property(nonatomic,strong) NSData * buttonIDs;


@end
