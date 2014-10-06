//
//  BRYCableConnectionSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRYCableConnectionSettingResult.h"
#import "BRMessage_Private.h"




@interface BRYCableConnectionSettingResult ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRYCableConnectionSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_Y_CABLE_CONNECTION_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRYCableConnectionSettingResult %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
