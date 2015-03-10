//
//  BRSetAntistartleCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetAntistartleCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetAntistartleCommand

#pragma mark - Public

+ (BRSetAntistartleCommand *)commandWithEnable:(BOOL)enable
{
	BRSetAntistartleCommand *instance = [[BRSetAntistartleCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ANTISTARTLE;
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
    return [NSString stringWithFormat:@"<BRSetAntistartleCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
