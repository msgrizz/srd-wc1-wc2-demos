//
//  BRGetPartitionInformationSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetPartitionInformationSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRGetPartitionInformationSettingRequest

#pragma BRSettingRequest

+ (BRGetPartitionInformationSettingRequest *)requestWithPartition:(uint16_t)partition
{
	BRGetPartitionInformationSettingRequest *instance = [[BRGetPartitionInformationSettingRequest alloc] init];
	instance.partition = partition;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_PARTITION_INFORMATION_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"partition", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetPartitionInformationSettingRequest %p> partition=0x%04X",
            self, self.partition];
}

@end
