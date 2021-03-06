//
//  BRRawButtonTestEventEnableDisableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRRawButtonTestEventEnableDisableEvent.h"
#import "BRMessage_Private.h"


@interface BRRawButtonTestEventEnableDisableEvent ()

@property(nonatomic,assign,readwrite) BOOL rawButtonEventEnable;


@end


@implementation BRRawButtonTestEventEnableDisableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RAW_BUTTONTEST_EVENT_ENABLEDISABLE_EVENT;
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
    return [NSString stringWithFormat:@"<BRRawButtonTestEventEnableDisableEvent %p> rawButtonEventEnable=%@",
            self, (self.rawButtonEventEnable ? @"YES" : @"NO")];
}

@end
