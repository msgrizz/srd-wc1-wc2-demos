//
//  BRVocalystInfoNumberSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVocalystInfoNumberSettingResult.h"
#import "BRMessage_Private.h"




@interface BRVocalystInfoNumberSettingResult ()

@property(nonatomic,strong,readwrite) NSString * infoPhoneNumber;


@end


@implementation BRVocalystInfoNumberSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOCALYST_INFO_NUMBER_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"infoPhoneNumber", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVocalystInfoNumberSettingResult %p> infoPhoneNumber=%@",
            self, self.infoPhoneNumber];
}

@end
