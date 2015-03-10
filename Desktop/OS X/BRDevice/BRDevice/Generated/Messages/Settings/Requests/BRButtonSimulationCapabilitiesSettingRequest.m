//
//  BRButtonSimulationCapabilitiesSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRButtonSimulationCapabilitiesSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRButtonSimulationCapabilitiesSettingRequest

#pragma BRSettingRequest

+ (BRButtonSimulationCapabilitiesSettingRequest *)request
{
	BRButtonSimulationCapabilitiesSettingRequest *instance = [[BRButtonSimulationCapabilitiesSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BUTTON_SIMULATION_CAPABILITIES_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRButtonSimulationCapabilitiesSettingRequest %p>",
            self];
}

@end
