//
//  BRApplicationActionResultEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRApplicationActionResultEvent.h"
#import "BRMessage_Private.h"




@interface BRApplicationActionResultEvent ()

@property(nonatomic,assign,readwrite) uint16_t featureID;
@property(nonatomic,assign,readwrite) uint16_t action;
@property(nonatomic,strong,readwrite) NSData * operatingData;
@property(nonatomic,strong,readwrite) NSData * resultData;


@end


@implementation BRApplicationActionResultEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_APPLICATION_ACTION_RESULT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"featureID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"action", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"operatingData", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"resultData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRApplicationActionResultEvent %p> featureID=0x%04X, action=0x%04X, operatingData=%@, resultData=%@",
            self, self.featureID, self.action, self.operatingData, self.resultData];
}

@end
