//
//  BRConfigureVRCallRejectAndAnswerCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureVRCallRejectAndAnswerCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureVRCallRejectAndAnswerCommand

#pragma mark - Public

+ (BRConfigureVRCallRejectAndAnswerCommand *)commandWithEnable:(BOOL)enable
{
	BRConfigureVRCallRejectAndAnswerCommand *instance = [[BRConfigureVRCallRejectAndAnswerCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_VR_CALL_REJECT_AND_ANSWER;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureVRCallRejectAndAnswerCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
