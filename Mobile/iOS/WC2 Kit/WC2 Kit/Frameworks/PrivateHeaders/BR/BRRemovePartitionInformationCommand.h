//
//  BRRemovePartitionInformationCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_REMOVE_PARTITION_INFORMATION 0x0E1C



@interface BRRemovePartitionInformationCommand : BRCommand

+ (BRRemovePartitionInformationCommand *)commandWithPartitionId:(uint16_t)partitionId;

@property(nonatomic,assign) uint16_t partitionId;


@end
