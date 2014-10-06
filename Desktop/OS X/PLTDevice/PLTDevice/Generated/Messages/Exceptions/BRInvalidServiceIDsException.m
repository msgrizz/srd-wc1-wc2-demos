//
//  BRInvalidServiceIDsException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRInvalidServiceIDsException.h"
#import "BRMessage_Private.h"




@interface BRInvalidServiceIDsException ()

@property(nonatomic,strong,readwrite) NSData * ids;


@end


@implementation BRInvalidServiceIDsException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INVALID_SERVICE_IDS_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"ids", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRInvalidServiceIDsException %p> ids=%@",
            self, self.ids];
}

@end
