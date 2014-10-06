//
//  BRConfigureWearingSensorEnabledCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureWearingSensorEnabledCommand.h"
#import "BRMessage_Private.h"




@implementation BRConfigureWearingSensorEnabledCommand

#pragma mark - Public

+ (BRConfigureWearingSensorEnabledCommand *)commandWithWearingStateSensorEnabled:(BOOL)wearingStateSensorEnabled
{
	BRConfigureWearingSensorEnabledCommand *instance = [[BRConfigureWearingSensorEnabledCommand alloc] init];
	instance.wearingStateSensorEnabled = wearingStateSensorEnabled;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_WEARING_SENSOR_ENABLED;
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
    return [NSString stringWithFormat:@"<BRConfigureWearingSensorEnabledCommand %p> wearingStateSensorEnabled=%@",
            self, (self.wearingStateSensorEnabled ? @"YES" : @"NO")];
}

@end
