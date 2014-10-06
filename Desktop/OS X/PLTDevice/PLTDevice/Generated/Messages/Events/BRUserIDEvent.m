//
//  BRUserIDEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRUserIDEvent.h"
#import "BRMessage_Private.h"




@interface BRUserIDEvent ()

@property(nonatomic,strong,readwrite) NSData * userID;


@end


@implementation BRUserIDEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USER_ID_EVENT;
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
    return [NSString stringWithFormat:@"<BRUserIDEvent %p> userID=%@",
            self, self.userID];
}

@end
