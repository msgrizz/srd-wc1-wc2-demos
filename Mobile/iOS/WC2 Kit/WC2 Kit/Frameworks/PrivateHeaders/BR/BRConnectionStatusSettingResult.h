//
//  BRConnectionStatusSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_CONNECTION_STATUS_SETTING_RESULT 0x0C00



@interface BRConnectionStatusSettingResult : BRSettingResult

@property(nonatomic,readonly) NSData * downstreamPortIDs;
@property(nonatomic,readonly) NSData * connectedPortIDs;
@property(nonatomic,readonly) uint8_t originatingPortID;


@end
