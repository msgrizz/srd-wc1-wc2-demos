//
//  BRPairingModeSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPairingModeSettingResult.h"
#import "BRMessage_Private.h"


@interface BRPairingModeSettingResult ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRPairingModeSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PAIRING_MODE_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRPairingModeSettingResult %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
