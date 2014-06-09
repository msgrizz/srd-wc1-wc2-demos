//
//  BRSignalStrengthSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


typedef enum {
    BRSignalStrengthDistanceFar =       0,
    BRSignalStrengthDistanceNear =      1,
    BRSignalStrengthDistanceUnknown =   2
} BRSignalStrengthDistance;


@interface BRSignalStrengthSettingResponse : BRSettingResponse

@property(nonatomic,readonly) uint8_t                   connectionID;
@property(nonatomic,readonly) uint8_t                   strength;
@property(nonatomic,readonly) BRSignalStrengthDistance  distance;

@end
