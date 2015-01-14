//
//  BRCapsenseRawDataEventEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCapsenseRawDataEventEvent.h"
#import "BRMessage_Private.h"


@interface BRCapsenseRawDataEventEvent ()

@property(nonatomic,strong,readwrite) NSData * capsenseRawData;


@end


@implementation BRCapsenseRawDataEventEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CAPSENSE_RAW_DATA_EVENT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"capsenseRawData", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCapsenseRawDataEventEvent %p> capsenseRawData=%@",
            self, self.capsenseRawData];
}

@end
