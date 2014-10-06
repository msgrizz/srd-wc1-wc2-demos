//
//  BRButtonSimulationCapabilitiesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRButtonSimulationCapabilitiesSettingResult.h"
#import "BRMessage_Private.h"




@interface BRButtonSimulationCapabilitiesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * supportedButtonIDs;


@end


@implementation BRButtonSimulationCapabilitiesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BUTTON_SIMULATION_CAPABILITIES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"supportedButtonIDs", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRButtonSimulationCapabilitiesSettingResult %p> supportedButtonIDs=%@",
            self, self.supportedButtonIDs];
}

@end
