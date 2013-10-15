//
//  AppDelegate.h
//  HT-CMX
//
//  Created by Davis, Morgan on 10/7/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#define DEFAULTS    [NSUserDefaults standardUserDefaults]


extern NSString *const PLTDefaultsKeyDefaultsVersion;
extern NSString *const PLTDefaultsKeyHTSensitivity;
extern NSString *const PLTDefaultsKeyImage;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
