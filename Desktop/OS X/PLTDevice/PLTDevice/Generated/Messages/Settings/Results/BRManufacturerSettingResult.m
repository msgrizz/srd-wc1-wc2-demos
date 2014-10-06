//
//  BRManufacturerSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRManufacturerSettingResult.h"
#import "BRMessage_Private.h"




@interface BRManufacturerSettingResult ()

@property(nonatomic,strong,readwrite) NSString * name;


@end


@implementation BRManufacturerSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MANUFACTURER_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"name", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRManufacturerSettingResult %p> name=%@",
            self, self.name];
}

@end
