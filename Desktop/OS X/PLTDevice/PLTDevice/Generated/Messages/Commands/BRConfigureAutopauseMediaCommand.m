//
//  BRConfigureAutopauseMediaCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureAutopauseMediaCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureAutopauseMediaCommand

#pragma mark - Public

+ (BRConfigureAutopauseMediaCommand *)commandWithAutoPauseMedia:(BOOL)autoPauseMedia
{
	BRConfigureAutopauseMediaCommand *instance = [[BRConfigureAutopauseMediaCommand alloc] init];
	instance.autoPauseMedia = autoPauseMedia;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_AUTOPAUSE_MEDIA;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoPauseMedia", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureAutopauseMediaCommand %p> autoPauseMedia=%@",
            self, (self.autoPauseMedia ? @"YES" : @"NO")];
}

@end
