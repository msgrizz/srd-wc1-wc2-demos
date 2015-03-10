//
//  BROneByteArraySettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BROneByteArraySettingResult.h"
#import "BRMessage_Private.h"


@interface BROneByteArraySettingResult ()

@property(nonatomic,strong,readwrite) NSData * value;


@end


@implementation BROneByteArraySettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ONE_BYTE_ARRAY_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROneByteArraySettingResult %p> value=%@",
            self, self.value];
}

@end
