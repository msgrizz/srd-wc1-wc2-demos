//
//  BRSetG616Command.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetG616Command.h"
#import "BRMessage_Private.h"


@implementation BRSetG616Command

#pragma mark - Public

+ (BRSetG616Command *)commandWithEnable:(BOOL)enable
{
	BRSetG616Command *instance = [[BRSetG616Command alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_G616;
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
    return [NSString stringWithFormat:@"<BRSetG616Command %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
