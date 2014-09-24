//
//  PLTSkinTemperatureInfo.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/20/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTInfo.h"


float PLTFahrenheitFromCelsius(float c);


@interface PLTSkinTemperatureInfo : PLTInfo

@property(nonatomic,readonly)	float	temperature;

@end
