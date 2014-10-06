//
//  BRTestInterfaceEnableDisableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTestInterfaceEnableDisableCommand.h"
#import "BRMessage_Private.h"




@implementation BRTestInterfaceEnableDisableCommand

#pragma mark - Public

+ (BRTestInterfaceEnableDisableCommand *)commandWithTestInterfaceEnable:(BOOL)testInterfaceEnable
{
	BRTestInterfaceEnableDisableCommand *instance = [[BRTestInterfaceEnableDisableCommand alloc] init];
	instance.testInterfaceEnable = testInterfaceEnable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TEST_INTERFACE_ENABLEDISABLE;
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
    return [NSString stringWithFormat:@"<BRTestInterfaceEnableDisableCommand %p> testInterfaceEnable=%@",
            self, (self.testInterfaceEnable ? @"YES" : @"NO")];
}

@end
