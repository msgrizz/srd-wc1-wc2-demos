//
//  BRGetDSPParametersSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_GET_DSP_PARAMETERS_SETTING_RESULT 0x0F42



@interface BRGetDSPParametersSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t codec;
@property(nonatomic,readonly) BOOL storeIsVolatile;
@property(nonatomic,readonly) int16_t parameterIndex;
@property(nonatomic,readonly) NSData * payload;


@end
