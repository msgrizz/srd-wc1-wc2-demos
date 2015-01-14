//
//  BRTxPowerReportingSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_TXPOWER_REPORTING_SETTING_REQUEST 0x0810



@interface BRTxPowerReportingSettingRequest : BRSettingRequest

+ (BRTxPowerReportingSettingRequest *)requestWithConnectionId:(uint8_t)connectionId;

@property(nonatomic,assign) uint8_t connectionId;


@end
