//
//  BRVocalystPhoneNumberSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVocalystPhoneNumberSettingResult.h"
#import "BRMessage_Private.h"




@interface BRVocalystPhoneNumberSettingResult ()

@property(nonatomic,strong,readwrite) NSString * vocalystPhoneNumber;


@end


@implementation BRVocalystPhoneNumberSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOCALYST_PHONE_NUMBER_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"vocalystPhoneNumber", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVocalystPhoneNumberSettingResult %p> vocalystPhoneNumber=%@",
            self, self.vocalystPhoneNumber];
}

@end
