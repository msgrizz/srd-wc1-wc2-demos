//
//  BRHalCurrentScenarioEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRHalCurrentScenarioEvent.h"
#import "BRMessage_Private.h"


@interface BRHalCurrentScenarioEvent ()

@property(nonatomic,assign,readwrite) uint16_t scenario;


@end


@implementation BRHalCurrentScenarioEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CURRENT_SCENARIO_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"scenario", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHalCurrentScenarioEvent %p> scenario=0x%04X",
            self, self.scenario];
}

@end
