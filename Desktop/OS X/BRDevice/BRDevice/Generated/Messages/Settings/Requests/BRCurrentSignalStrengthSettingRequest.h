//
//  BRCurrentSignalStrengthSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_CURRENT_SIGNAL_STRENGTH_SETTING_REQUEST 0x0800

#define BRDefinedValue_CurrentSignalStrengthSettingRequest_ConnectionId_Far 0
#define BRDefinedValue_CurrentSignalStrengthSettingRequest_ConnectionId_Near 1
#define BRDefinedValue_CurrentSignalStrengthSettingRequest_ConnectionId_Unknown 2


@interface BRCurrentSignalStrengthSettingRequest : BRSettingRequest

+ (BRCurrentSignalStrengthSettingRequest *)requestWithConnectionId:(uint8_t)connectionId;

@property(nonatomic,assign) uint8_t connectionId;


@end
