//
//  BRFeatureLockSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRFeatureLockSettingResult.h"
#import "BRMessage_Private.h"


@interface BRFeatureLockSettingResult ()

@property(nonatomic,strong,readwrite) NSData * commands;


@end


@implementation BRFeatureLockSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FEATURE_LOCK_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRFeatureLockSettingResult %p> commands=%@",
            self, self.commands];
}

@end
