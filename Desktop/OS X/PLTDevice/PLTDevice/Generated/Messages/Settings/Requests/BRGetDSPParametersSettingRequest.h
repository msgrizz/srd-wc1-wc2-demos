//
//  BRGetDSPParametersSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_GET_DSP_PARAMETERS_SETTING_REQUEST 0x0F42



@interface BRGetDSPParametersSettingRequest : BRSettingRequest

+ (BRGetDSPParametersSettingRequest *)requestWithCodec:(uint8_t)codec storeIsVolatile:(BOOL)storeIsVolatile parameterIndex:(int16_t)parameterIndex;

@property(nonatomic,assign) uint8_t codec;
@property(nonatomic,assign) BOOL storeIsVolatile;
@property(nonatomic,assign) int16_t parameterIndex;


@end
