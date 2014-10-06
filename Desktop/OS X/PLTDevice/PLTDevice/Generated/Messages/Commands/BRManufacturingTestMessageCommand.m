//
//  BRManufacturingTestMessageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRManufacturingTestMessageCommand.h"
#import "BRMessage_Private.h"




@implementation BRManufacturingTestMessageCommand

#pragma mark - Public

+ (BRManufacturingTestMessageCommand *)commandWithData:(NSData *)data
{
	BRManufacturingTestMessageCommand *instance = [[BRManufacturingTestMessageCommand alloc] init];
	instance.data = data;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MANUFACTURING_TEST_MESSAGE;
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
    return [NSString stringWithFormat:@"<BRManufacturingTestMessageCommand %p> data=%@",
            self, self.data];
}

@end
