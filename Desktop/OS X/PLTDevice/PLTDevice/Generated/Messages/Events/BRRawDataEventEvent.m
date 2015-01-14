//
//  BRRawDataEventEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRawDataEventEvent.h"
#import "BRMessage_Private.h"


@interface BRRawDataEventEvent ()

@property(nonatomic,strong,readwrite) NSData * rawDataEventId;


@end


@implementation BRRawDataEventEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RAW_DATA_EVENT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"rawDataEventId", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRRawDataEventEvent %p> rawDataEventId=%@",
            self, self.rawDataEventId];
}

@end
