//
//  BRConfigureA2DPCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureA2DPCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureA2DPCommand

#pragma mark - Public

+ (BRConfigureA2DPCommand *)commandWithEnable:(BOOL)enable
{
	BRConfigureA2DPCommand *instance = [[BRConfigureA2DPCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_A2DP;
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
    return [NSString stringWithFormat:@"<BRConfigureA2DPCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
