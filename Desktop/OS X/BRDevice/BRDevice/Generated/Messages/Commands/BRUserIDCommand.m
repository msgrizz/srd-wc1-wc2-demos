//
//  BRUserIDCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRUserIDCommand.h"
#import "BRMessage_Private.h"


@implementation BRUserIDCommand

#pragma mark - Public

+ (BRUserIDCommand *)commandWithUserID:(NSData *)userID
{
	BRUserIDCommand *instance = [[BRUserIDCommand alloc] init];
	instance.userID = userID;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USER_ID;
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
    return [NSString stringWithFormat:@"<BRUserIDCommand %p> userID=%@",
            self, self.userID];
}

@end
