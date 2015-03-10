//
//  BRInvalidServiceModesException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRInvalidServiceModesException.h"
#import "BRMessage_Private.h"


@interface BRInvalidServiceModesException ()

@property(nonatomic,strong,readwrite) NSData * modes;


@end


@implementation BRInvalidServiceModesException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INVALID_SERVICE_MODES_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"modes", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRInvalidServiceModesException %p> modes=%@",
            self, self.modes];
}

@end
