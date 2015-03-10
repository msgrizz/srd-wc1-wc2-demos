//
//  BRGetPartitionInformationSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_GET_PARTITION_INFORMATION_SETTING_REQUEST 0x0E1C



@interface BRGetPartitionInformationSettingRequest : BRSettingRequest

+ (BRGetPartitionInformationSettingRequest *)requestWithPartition:(uint16_t)partition;

@property(nonatomic,assign) uint16_t partition;


@end
