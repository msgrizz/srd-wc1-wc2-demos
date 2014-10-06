//
//  BRHeadsetAvailableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHeadsetAvailableCommand.h"
#import "BRMessage_Private.h"




@implementation BRHeadsetAvailableCommand

#pragma mark - Public

+ (BRHeadsetAvailableCommand *)commandWithState:(BOOL)state
{
	BRHeadsetAvailableCommand *instance = [[BRHeadsetAvailableCommand alloc] init];
	instance.state = state;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HEADSET_AVAILABLE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"state", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHeadsetAvailableCommand %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
