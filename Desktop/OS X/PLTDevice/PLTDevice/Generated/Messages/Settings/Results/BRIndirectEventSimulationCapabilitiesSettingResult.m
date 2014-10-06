//
//  BRIndirectEventSimulationCapabilitiesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIndirectEventSimulationCapabilitiesSettingResult.h"
#import "BRMessage_Private.h"




@interface BRIndirectEventSimulationCapabilitiesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * supportedIndirectEventIDs;


@end


@implementation BRIndirectEventSimulationCapabilitiesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"supportedIndirectEventIDs", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRIndirectEventSimulationCapabilitiesSettingResult %p> supportedIndirectEventIDs=%@",
            self, self.supportedIndirectEventIDs];
}

@end
