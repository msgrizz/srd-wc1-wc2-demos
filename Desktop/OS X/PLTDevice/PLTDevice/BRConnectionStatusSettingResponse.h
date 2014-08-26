//
//  BRConnectionStatusSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 7/17/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRConnectionStatusSettingResponse : BRSettingResponse

@property(nonatomic,readonly) NSArray   *downstreamPortIDs;
@property(nonatomic,readonly) NSArray   *connectedPortIDs;
@property(nonatomic,readonly) uint8_t	originatingPortID;

@end
