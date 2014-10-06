//
//  BRSetPairingModeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetPairingModeCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetPairingModeCommand

#pragma mark - Public

+ (BRSetPairingModeCommand *)commandWithEnable:(BOOL)enable
{
	BRSetPairingModeCommand *instance = [[BRSetPairingModeCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_PAIRING_MODE;
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
    return [NSString stringWithFormat:@"<BRSetPairingModeCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
