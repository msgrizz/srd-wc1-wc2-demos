//
//  BRNumberOutOfRangeException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRNumberOutOfRangeException.h"
#import "BRMessage_Private.h"




@interface BRNumberOutOfRangeException ()

@property(nonatomic,assign,readwrite) int32_t minimum;
@property(nonatomic,assign,readwrite) int32_t maximum;


@end


@implementation BRNumberOutOfRangeException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_NUMBER_OUT_OF_RANGE_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"minimum", @"type": @(BRPayloadItemTypeLong)},
			@{@"name": @"maximum", @"type": @(BRPayloadItemTypeLong)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRNumberOutOfRangeException %p> minimum=0x%08X, maximum=0x%08X",
            self, self.minimum, self.maximum];
}

@end
