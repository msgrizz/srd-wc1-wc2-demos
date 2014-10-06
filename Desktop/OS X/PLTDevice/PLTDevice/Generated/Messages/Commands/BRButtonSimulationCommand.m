//
//  BRButtonSimulationCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRButtonSimulationCommand.h"
#import "BRMessage_Private.h"


const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionSkp = 0x00;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionMkp = 0x01;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionLkp = 0x02;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionVlkp = 0x03;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionDkp = 0x04;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionVvlkp = 0x05;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionSlkp = 0x06;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionPress = 0x07;
const uint8_t ButtonSimulationCommand_ButtonAction_ButtonActionRelease = 0x08;


@implementation BRButtonSimulationCommand

#pragma mark - Public

+ (BRButtonSimulationCommand *)commandWithButtonAction:(uint8_t)buttonAction buttonIDs:(NSData *)buttonIDs
{
	BRButtonSimulationCommand *instance = [[BRButtonSimulationCommand alloc] init];
	instance.buttonAction = buttonAction;
	instance.buttonIDs = buttonIDs;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BUTTON_SIMULATION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"buttonAction", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"buttonIDs", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRButtonSimulationCommand %p> buttonAction=0x%02X, buttonIDs=%@",
            self, self.buttonAction, self.buttonIDs];
}

@end
