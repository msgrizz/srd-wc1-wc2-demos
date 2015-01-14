//
//  BRFeatureLockMaskSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFeatureLockMaskSettingResult.h"
#import "BRMessage_Private.h"


@interface BRFeatureLockMaskSettingResult ()

@property(nonatomic,strong,readwrite) NSData * commands;


@end


@implementation BRFeatureLockMaskSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FEATURE_LOCK_MASK_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"commands", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRFeatureLockMaskSettingResult %p> commands=%@",
            self, self.commands];
}

@end
