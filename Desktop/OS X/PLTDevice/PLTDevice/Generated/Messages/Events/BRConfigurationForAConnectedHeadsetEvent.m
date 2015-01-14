//
//  BRConfigurationForAConnectedHeadsetEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigurationForAConnectedHeadsetEvent.h"
#import "BRMessage_Private.h"


@interface BRConfigurationForAConnectedHeadsetEvent ()

@property(nonatomic,assign,readwrite) uint8_t configuration;


@end


@implementation BRConfigurationForAConnectedHeadsetEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET_EVENT;
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
    return [NSString stringWithFormat:@"<BRConfigurationForAConnectedHeadsetEvent %p> configuration=0x%02X",
            self, self.configuration];
}

@end
