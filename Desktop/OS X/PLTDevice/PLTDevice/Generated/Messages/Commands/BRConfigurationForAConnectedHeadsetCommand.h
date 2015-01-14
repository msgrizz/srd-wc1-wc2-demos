//
//  BRConfigurationForAConnectedHeadsetCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET 0x0401

#define BRDefinedValue_ConfigurationForAConnectedHeadsetCommand_Configuration_HTopNew 0x00
#define BRDefinedValue_ConfigurationForAConnectedHeadsetCommand_Configuration_HTopLegacy 0x01


@interface BRConfigurationForAConnectedHeadsetCommand : BRCommand

+ (BRConfigurationForAConnectedHeadsetCommand *)commandWithConfiguration:(uint8_t)configuration;

@property(nonatomic,assign) uint8_t configuration;


@end
