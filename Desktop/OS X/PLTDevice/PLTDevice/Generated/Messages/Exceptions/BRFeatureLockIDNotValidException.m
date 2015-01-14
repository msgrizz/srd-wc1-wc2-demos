//
//  BRFeatureLockIDNotValidException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFeatureLockIDNotValidException.h"
#import "BRMessage_Private.h"


@interface BRFeatureLockIDNotValidException ()

@property(nonatomic,strong,readwrite) NSData * commands;


@end


@implementation BRFeatureLockIDNotValidException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FEATURE_LOCK_ID_NOT_VALID_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRFeatureLockIDNotValidException %p> commands=%@",
            self, self.commands];
}

@end
