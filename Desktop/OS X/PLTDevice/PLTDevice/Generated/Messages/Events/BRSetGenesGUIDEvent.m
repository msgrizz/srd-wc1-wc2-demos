//
//  BRSetGenesGUIDEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetGenesGUIDEvent.h"
#import "BRMessage_Private.h"




@interface BRSetGenesGUIDEvent ()

@property(nonatomic,strong,readwrite) NSData * guid;


@end


@implementation BRSetGenesGUIDEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_GENES_GUID_EVENT;
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
    return [NSString stringWithFormat:@"<BRSetGenesGUIDEvent %p> guid=%@",
            self, self.guid];
}

@end
