//
//  BROneByteSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROneByteSettingResult.h"
#import "BRMessage_Private.h"


@interface BROneByteSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t value;


@end


@implementation BROneByteSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ONE_BYTE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROneByteSettingResult %p> value=0x%02X",
            self, self.value];
}

@end
