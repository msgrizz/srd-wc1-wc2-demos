//
//  KubiViewController.h
//  PLTSensor
//
//  Created by Morgan Davis on 12/9/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	PLTKubiPositioningModeJoystick,
	PLTKubiPositioningModeAbsolute
} PLTKubiPositioningMode;


NSString *NSStringFromPLTKubiPositioningMode(PLTKubiPositioningMode mode);


@interface KubiViewController : UIViewController

@end
