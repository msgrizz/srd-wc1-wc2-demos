//
//  BRIndirectEventSimulationCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIndirectEventSimulationCommand.h"
#import "BRMessage_Private.h"


const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventHeadsetWearingState = 0x00;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventBatteryStatusMonitoring = 0x01;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventVoiceRecognition = 0x02;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventProximity = 0x03;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventVoicePromptGeneration = 0x04;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventLedIndicationGeneration = 0x05;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventChargerConnectionState = 0x06;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventBatteryLevelChange = 0x07;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventUSBAudioChange = 0x08;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventQDConnectionState = 0x09;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventAalAcousticIncidentReport = 0x0A;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventAalTwaReport = 0x0B;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventConversationDynamicsReport = 0x0C;
const uint16_t IndirectEventSimulationCommand_IndirectEvent_IndirectEventYCableConnectionState = 0x0D;


@implementation BRIndirectEventSimulationCommand

#pragma mark - Public

+ (BRIndirectEventSimulationCommand *)commandWithIndirectEvent:(uint16_t)indirectEvent eventParameter:(NSData *)eventParameter
{
	BRIndirectEventSimulationCommand *instance = [[BRIndirectEventSimulationCommand alloc] init];
	instance.indirectEvent = indirectEvent;
	instance.eventParameter = eventParameter;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INDIRECT_EVENT_SIMULATION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"indirectEvent", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"eventParameter", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRIndirectEventSimulationCommand %p> indirectEvent=0x%04X, eventParameter=%@",
            self, self.indirectEvent, self.eventParameter];
}

@end
