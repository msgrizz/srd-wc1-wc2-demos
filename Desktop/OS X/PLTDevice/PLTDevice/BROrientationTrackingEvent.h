//
//  BROrientationTrackingEvent.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BREvent.h"


typedef struct {
	double x;
	double y;
	double z;
} PLTEulerAngles;

typedef struct {
	double w;
	double x;
	double y;
	double z;
} PLTQuaternion;


NSString *NSStringFromEulerAngles(PLTEulerAngles angles);
NSString *NSStringFromQuaternion(PLTQuaternion quaternion);


@interface BROrientationTrackingEvent : BREvent

@property(nonatomic,readonly) PLTEulerAngles    rawEulerAngles;
@property(nonatomic,readonly) PLTQuaternion     rawQuaternion;

@end
