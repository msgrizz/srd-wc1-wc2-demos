//
//  BRIndirectEventSimulationCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_INDIRECT_EVENT_SIMULATION 0x1004

#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventHeadsetWearingState 0x00
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventBatteryStatusMonitoring 0x01
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventVoiceRecognition 0x02
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventProximity 0x03
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventVoicePromptGeneration 0x04
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventLedIndicationGeneration 0x05
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventChargerConnectionState 0x06
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventBatteryLevelChange 0x07
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventUSBAudioChange 0x08
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventQDConnectionState 0x09
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventAalAcousticIncidentReport 0x0A
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventAalTwaReport 0x0B
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventConversationDynamicsReport 0x0C
#define BRDefinedValue_IndirectEventSimulationCommand_IndirectEvent_IndirectEventYCableConnectionState 0x0D


@interface BRIndirectEventSimulationCommand : BRCommand

+ (BRIndirectEventSimulationCommand *)commandWithIndirectEvent:(uint16_t)indirectEvent eventParameter:(NSData *)eventParameter;

@property(nonatomic,assign) uint16_t indirectEvent;
@property(nonatomic,strong) NSData * eventParameter;


@end