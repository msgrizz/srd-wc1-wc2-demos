//
//  BRConfigureAutopauseMediaEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureAutopauseMediaEvent.h"
#import "BRMessage_Private.h"




@interface BRConfigureAutopauseMediaEvent ()

@property(nonatomic,assign,readwrite) BOOL autoPauseMedia;


@end


@implementation BRConfigureAutopauseMediaEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_AUTOPAUSE_MEDIA_EVENT;
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
    return [NSString stringWithFormat:@"<BRConfigureAutopauseMediaEvent %p> autoPauseMedia=%@",
            self, (self.autoPauseMedia ? @"YES" : @"NO")];
}

@end
