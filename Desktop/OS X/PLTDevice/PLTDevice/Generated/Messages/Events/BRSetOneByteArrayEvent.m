//
//  BRSetOneByteArrayEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOneByteArrayEvent.h"
#import "BRMessage_Private.h"




@interface BRSetOneByteArrayEvent ()

@property(nonatomic,strong,readwrite) NSData * value;


@end


@implementation BRSetOneByteArrayEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_BYTE_ARRAY_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneByteArrayEvent %p> value=%@",
            self, self.value];
}

@end
