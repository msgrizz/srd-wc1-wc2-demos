//
//  BRIllegalValueException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIllegalValueException.h"
#import "BRMessage_Private.h"


@interface BRIllegalValueException ()

@property(nonatomic,assign,readwrite) int32_t value;


@end


@implementation BRIllegalValueException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ILLEGAL_VALUE_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeLong)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRIllegalValueException %p> value=0x%08X",
            self, self.value];
}

@end
