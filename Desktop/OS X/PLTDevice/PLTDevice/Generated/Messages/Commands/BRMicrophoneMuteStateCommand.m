//
//  BRMicrophoneMuteStateCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMicrophoneMuteStateCommand.h"
#import "BRMessage_Private.h"




@implementation BRMicrophoneMuteStateCommand

#pragma mark - Public

+ (BRMicrophoneMuteStateCommand *)commandWithState:(BOOL)state
{
	BRMicrophoneMuteStateCommand *instance = [[BRMicrophoneMuteStateCommand alloc] init];
	instance.state = state;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MICROPHONE_MUTE_STATE;
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
    return [NSString stringWithFormat:@"<BRMicrophoneMuteStateCommand %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
