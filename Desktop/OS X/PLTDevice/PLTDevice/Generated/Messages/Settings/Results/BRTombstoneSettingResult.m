//
//  BRTombstoneSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTombstoneSettingResult.h"
#import "BRMessage_Private.h"


@interface BRTombstoneSettingResult ()

@property(nonatomic,strong,readwrite) NSData * crashDump;


@end


@implementation BRTombstoneSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TOMBSTONE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"crashDump", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTombstoneSettingResult %p> crashDump=%@",
            self, self.crashDump];
}

@end
