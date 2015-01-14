//
//  BRConfigureWearingSensorEnabledEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureWearingSensorEnabledEvent.h"
#import "BRMessage_Private.h"


@interface BRConfigureWearingSensorEnabledEvent ()

@property(nonatomic,assign,readwrite) BOOL wearingStateSensorEnabled;


@end


@implementation BRConfigureWearingSensorEnabledEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_WEARING_SENSOR_ENABLED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"wearingStateSensorEnabled", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureWearingSensorEnabledEvent %p> wearingStateSensorEnabled=%@",
            self, (self.wearingStateSensorEnabled ? @"YES" : @"NO")];
}

@end
