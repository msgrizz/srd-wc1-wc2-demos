//
//  BRPartNumberEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRPartNumberEvent.h"
#import "BRMessage_Private.h"


@interface BRPartNumberEvent ()

@property(nonatomic,assign,readwrite) uint32_t partNumber;


@end


@implementation BRPartNumberEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PART_NUMBER_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"partNumber", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPartNumberEvent %p> partNumber=0x%08X",
            self, self.partNumber];
}

@end
