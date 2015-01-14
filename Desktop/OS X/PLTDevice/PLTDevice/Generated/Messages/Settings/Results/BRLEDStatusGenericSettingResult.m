//
//  BRLEDStatusGenericSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLEDStatusGenericSettingResult.h"
#import "BRMessage_Private.h"


@interface BRLEDStatusGenericSettingResult ()

@property(nonatomic,strong,readwrite) NSData * iD;
@property(nonatomic,strong,readwrite) NSData * color;
@property(nonatomic,strong,readwrite) NSData * state;


@end


@implementation BRLEDStatusGenericSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LED_STATUS_GENERIC_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"iD", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"color", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"state", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRLEDStatusGenericSettingResult %p> iD=%@, color=%@, state=%@",
            self, self.iD, self.color, self.state];
}

@end
