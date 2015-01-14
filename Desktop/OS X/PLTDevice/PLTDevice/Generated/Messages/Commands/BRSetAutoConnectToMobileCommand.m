//
//  BRSetAutoConnectToMobileCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetAutoConnectToMobileCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetAutoConnectToMobileCommand

#pragma mark - Public

+ (BRSetAutoConnectToMobileCommand *)commandWithAutoConnect:(BOOL)autoConnect
{
	BRSetAutoConnectToMobileCommand *instance = [[BRSetAutoConnectToMobileCommand alloc] init];
	instance.autoConnect = autoConnect;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_AUTOCONNECT_TO_MOBILE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoConnect", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetAutoConnectToMobileCommand %p> autoConnect=%@",
            self, (self.autoConnect ? @"YES" : @"NO")];
}

@end
