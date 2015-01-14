//
//  BRUserDefinedStorageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRUserDefinedStorageCommand.h"
#import "BRMessage_Private.h"


@implementation BRUserDefinedStorageCommand

#pragma mark - Public

+ (BRUserDefinedStorageCommand *)commandWithData:(NSData *)data
{
	BRUserDefinedStorageCommand *instance = [[BRUserDefinedStorageCommand alloc] init];
	instance.data = data;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USER_DEFINED_STORAGE;
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
    return [NSString stringWithFormat:@"<BRUserDefinedStorageCommand %p> data=%@",
            self, self.data];
}

@end
