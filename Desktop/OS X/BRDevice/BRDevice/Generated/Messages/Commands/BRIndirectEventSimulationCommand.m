//
//  BRIndirectEventSimulationCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRIndirectEventSimulationCommand.h"
#import "BRMessage_Private.h"


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
