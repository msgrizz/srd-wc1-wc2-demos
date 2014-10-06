//
//  BRGetPartitionInformationSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetPartitionInformationSettingResult.h"
#import "BRMessage_Private.h"




@interface BRGetPartitionInformationSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t partition;
@property(nonatomic,assign,readwrite) uint16_t partitionId;
@property(nonatomic,assign,readwrite) uint16_t version;
@property(nonatomic,assign,readwrite) uint16_t partitionNumber;


@end


@implementation BRGetPartitionInformationSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_PARTITION_INFORMATION_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"partition", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"partitionId", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"version", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"partitionNumber", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetPartitionInformationSettingResult %p> partition=0x%04X, partitionId=0x%04X, version=0x%04X, partitionNumber=0x%04X",
            self, self.partition, self.partitionId, self.version, self.partitionNumber];
}

@end
