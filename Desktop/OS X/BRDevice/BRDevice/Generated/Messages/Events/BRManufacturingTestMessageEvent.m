//
//  BRManufacturingTestMessageEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRManufacturingTestMessageEvent.h"
#import "BRMessage_Private.h"


@interface BRManufacturingTestMessageEvent ()

@property(nonatomic,strong,readwrite) NSData * data;


@end


@implementation BRManufacturingTestMessageEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MANUFACTURING_TEST_MESSAGE_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"data", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRManufacturingTestMessageEvent %p> data=%@",
            self, self.data];
}

@end
