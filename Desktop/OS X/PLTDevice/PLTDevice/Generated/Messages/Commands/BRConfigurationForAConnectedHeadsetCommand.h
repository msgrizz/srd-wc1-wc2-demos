//
//  BRConfigurationForAConnectedHeadsetCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET 0x0401

extern const uint8_t ConfigurationForAConnectedHeadsetCommand_Configuration_HTopNew;
extern const uint8_t ConfigurationForAConnectedHeadsetCommand_Configuration_HTopLegacy;


@interface BRConfigurationForAConnectedHeadsetCommand : BRCommand

+ (BRConfigurationForAConnectedHeadsetCommand *)commandWithConfiguration:(uint8_t)configuration;

@property(nonatomic,assign) uint8_t configuration;


@end
