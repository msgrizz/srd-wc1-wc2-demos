//
//  BRTestInterfaceEnableDisableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTestInterfaceEnableDisableEvent.h"
#import "BRMessage_Private.h"


@interface BRTestInterfaceEnableDisableEvent ()

@property(nonatomic,assign,readwrite) BOOL testInterfaceEnable;


@end


@implementation BRTestInterfaceEnableDisableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TEST_INTERFACE_ENABLEDISABLE_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"testInterfaceEnable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTestInterfaceEnableDisableEvent %p> testInterfaceEnable=%@",
            self, (self.testInterfaceEnable ? @"YES" : @"NO")];
}

@end
