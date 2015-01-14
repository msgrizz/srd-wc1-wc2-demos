//
//  BRGetPartitionInformationSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_GET_PARTITION_INFORMATION_SETTING_RESULT 0x0E1C



@interface BRGetPartitionInformationSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t partition;
@property(nonatomic,readonly) uint16_t partitionId;
@property(nonatomic,readonly) uint16_t version;
@property(nonatomic,readonly) uint16_t partitionNumber;


@end
