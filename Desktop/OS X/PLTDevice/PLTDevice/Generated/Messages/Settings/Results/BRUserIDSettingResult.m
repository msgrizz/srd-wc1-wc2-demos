//
//  BRUserIDSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRUserIDSettingResult.h"
#import "BRMessage_Private.h"


@interface BRUserIDSettingResult ()

@property(nonatomic,strong,readwrite) NSData * userID;


@end


@implementation BRUserIDSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USER_ID_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"userID", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRUserIDSettingResult %p> userID=%@",
            self, self.userID];
}

@end
