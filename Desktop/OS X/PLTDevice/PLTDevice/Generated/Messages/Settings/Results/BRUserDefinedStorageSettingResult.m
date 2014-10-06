//
//  BRUserDefinedStorageSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRUserDefinedStorageSettingResult.h"
#import "BRMessage_Private.h"




@interface BRUserDefinedStorageSettingResult ()

@property(nonatomic,strong,readwrite) NSData * data;


@end


@implementation BRUserDefinedStorageSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USER_DEFINED_STORAGE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"data", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRUserDefinedStorageSettingResult %p> data=%@",
            self, self.data];
}

@end
