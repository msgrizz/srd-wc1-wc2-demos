//
//  BRGenesGUIDSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGenesGUIDSettingResult.h"
#import "BRMessage_Private.h"


@interface BRGenesGUIDSettingResult ()

@property(nonatomic,strong,readwrite) NSData * guid;


@end


@implementation BRGenesGUIDSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GENES_GUID_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"guid", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGenesGUIDSettingResult %p> guid=%@",
            self, self.guid];
}

@end
