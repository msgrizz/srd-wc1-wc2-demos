//
//  BRRawButtonTestEventEnableDisableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRawButtonTestEventEnableDisableCommand.h"
#import "BRMessage_Private.h"


@implementation BRRawButtonTestEventEnableDisableCommand

#pragma mark - Public

+ (BRRawButtonTestEventEnableDisableCommand *)commandWithRawButtonEventEnable:(BOOL)rawButtonEventEnable
{
	BRRawButtonTestEventEnableDisableCommand *instance = [[BRRawButtonTestEventEnableDisableCommand alloc] init];
	instance.rawButtonEventEnable = rawButtonEventEnable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RAW_BUTTONTEST_EVENT_ENABLEDISABLE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"rawButtonEventEnable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRRawButtonTestEventEnableDisableCommand %p> rawButtonEventEnable=%@",
            self, (self.rawButtonEventEnable ? @"YES" : @"NO")];
}

@end
