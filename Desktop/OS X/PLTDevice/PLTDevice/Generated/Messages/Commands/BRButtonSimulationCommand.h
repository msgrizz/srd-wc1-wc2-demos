//
//  BRButtonSimulationCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_BUTTON_SIMULATION 0x1002

extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionSkp;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionMkp;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionLkp;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionVlkp;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionDkp;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionVvlkp;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionSlkp;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionPress;
extern const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionRelease;


@interface BRButtonSimulationCommand : BRCommand

+ (BRButtonSimulationCommand *)commandWithButtonAction:(uint8_t)buttonAction buttonIDs:(NSData *)buttonIDs;

@property(nonatomic,assign) uint8_t buttonAction;
@property(nonatomic,strong) NSData * buttonIDs;


@end
