//
//  PLTAccelerationInfo.h
//  PLTDevice
//
//  Created by Morgan Davis on 12/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTInfo.h"


typedef struct {
	double x;
	double y;
	double z;
} PLTAcceleration;


NSString *NSStringFromAcceleration(PLTAcceleration acceleration);


@interface PLTAccelerationInfo : PLTInfo

@property(nonatomic,readonly)	PLTAcceleration	acceleration;

@end
