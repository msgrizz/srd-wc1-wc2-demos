//
//  BRSetStopAutoConnectOnDockCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetStopAutoConnectOnDockCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetStopAutoConnectOnDockCommand

#pragma mark - Public

+ (BRSetStopAutoConnectOnDockCommand *)commandWithStopAutoConnect:(BOOL)stopAutoConnect
{
	BRSetStopAutoConnectOnDockCommand *instance = [[BRSetStopAutoConnectOnDockCommand alloc] init];
	instance.stopAutoConnect = stopAutoConnect;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_STOP_AUTOCONNECT_ON_DOCK;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"stopAutoConnect", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetStopAutoConnectOnDockCommand %p> stopAutoConnect=%@",
            self, (self.stopAutoConnect ? @"YES" : @"NO")];
}

@end
