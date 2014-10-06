//
//  BROneShortSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROneShortSettingResult.h"
#import "BRMessage_Private.h"




@interface BROneShortSettingResult ()

@property(nonatomic,assign,readwrite) int16_t value;


@end


@implementation BROneShortSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ONE_SHORT_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROneShortSettingResult %p> value=0x%04X",
            self, self.value];
}

@end
