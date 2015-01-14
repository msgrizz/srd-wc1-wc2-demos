//
//  BRSetGenesGUIDCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetGenesGUIDCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetGenesGUIDCommand

#pragma mark - Public

+ (BRSetGenesGUIDCommand *)commandWithGuid:(NSData *)guid
{
	BRSetGenesGUIDCommand *instance = [[BRSetGenesGUIDCommand alloc] init];
	instance.guid = guid;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_GENES_GUID;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"guid", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetGenesGUIDCommand %p> guid=%@",
            self, self.guid];
}

@end
