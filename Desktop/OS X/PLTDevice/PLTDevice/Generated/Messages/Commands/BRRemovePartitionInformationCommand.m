//
//  BRRemovePartitionInformationCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRemovePartitionInformationCommand.h"
#import "BRMessage_Private.h"


@implementation BRRemovePartitionInformationCommand

#pragma mark - Public

+ (BRRemovePartitionInformationCommand *)commandWithPartitionId:(uint16_t)partitionId
{
	BRRemovePartitionInformationCommand *instance = [[BRRemovePartitionInformationCommand alloc] init];
	instance.partitionId = partitionId;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_REMOVE_PARTITION_INFORMATION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"partitionId", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRRemovePartitionInformationCommand %p> partitionId=0x%04X",
            self, self.partitionId];
}

@end
