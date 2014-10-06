//
//  BRConfigureAutomuteCallCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureAutomuteCallCommand.h"
#import "BRMessage_Private.h"




@implementation BRConfigureAutomuteCallCommand

#pragma mark - Public

+ (BRConfigureAutomuteCallCommand *)commandWithAutoMuteCall:(BOOL)autoMuteCall
{
	BRConfigureAutomuteCallCommand *instance = [[BRConfigureAutomuteCallCommand alloc] init];
	instance.autoMuteCall = autoMuteCall;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_AUTOMUTE_CALL;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoMuteCall", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureAutomuteCallCommand %p> autoMuteCall=%@",
            self, (self.autoMuteCall ? @"YES" : @"NO")];
}

@end
