//
//  BRCurrentSignalStrengthSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_CURRENT_SIGNAL_STRENGTH_SETTING_REQUEST 0x0800

extern const uint8_t CurrentSignalStrengthSettingRequest_ConnectionId_Far;
extern const uint8_t CurrentSignalStrengthSettingRequest_ConnectionId_Near;
extern const uint8_t CurrentSignalStrengthSettingRequest_ConnectionId_Unknown;


@interface BRCurrentSignalStrengthSettingRequest : BRSettingRequest

+ (BRCurrentSignalStrengthSettingRequest *)requestWithConnectionId:(uint8_t)connectionId;

@property(nonatomic,assign) uint8_t connectionId;


@end
