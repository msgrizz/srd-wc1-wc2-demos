//
//  BROneShortArraySettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROneShortArraySettingResult.h"
#import "BRMessage_Private.h"




@interface BROneShortArraySettingResult ()

@property(nonatomic,strong,readwrite) NSData * value;


@end


@implementation BROneShortArraySettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ONE_SHORT_ARRAY_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROneShortArraySettingResult %p> value=%@",
            self, self.value];
}

@end
