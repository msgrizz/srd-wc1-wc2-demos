//
//  BRConfigurationForAConnectedHeadsetCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigurationForAConnectedHeadsetCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigurationForAConnectedHeadsetCommand

#pragma mark - Public

+ (BRConfigurationForAConnectedHeadsetCommand *)commandWithConfiguration:(uint8_t)configuration
{
	BRConfigurationForAConnectedHeadsetCommand *instance = [[BRConfigurationForAConnectedHeadsetCommand alloc] init];
	instance.configuration = configuration;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"configuration", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigurationForAConnectedHeadsetCommand %p> configuration=0x%02X",
            self, self.configuration];
}

@end
