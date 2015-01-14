//
//  BRPartNumberSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPartNumberSettingResult.h"
#import "BRMessage_Private.h"


@interface BRPartNumberSettingResult ()

@property(nonatomic,assign,readwrite) uint32_t partNumber;


@end


@implementation BRPartNumberSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PART_NUMBER_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"partNumber", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPartNumberSettingResult %p> partNumber=0x%08X",
            self, self.partNumber];
}

@end
