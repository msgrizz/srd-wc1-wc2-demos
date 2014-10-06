//
//  BRHalCurrentEQSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_HAL_CURRENT_EQ_SETTING_REQUEST 0x1104



@interface BRHalCurrentEQSettingRequest : BRSettingRequest

+ (BRHalCurrentEQSettingRequest *)requestWithScenario:(uint16_t)scenario eQs:(NSData *)eQs;

@property(nonatomic,assign) uint16_t scenario;
@property(nonatomic,strong) NSData * eQs;


@end
