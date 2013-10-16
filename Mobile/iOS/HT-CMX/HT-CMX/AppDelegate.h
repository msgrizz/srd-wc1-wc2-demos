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
extern NSString *const PLTDefaultsKeySensitivity;
extern NSString *const PLTDefaultsKeySmoothing;
extern NSString *const PLTDefaultsKeyImage;
extern NSString *const PLTDefaultsKeyScale;
extern NSString *const PLTDefaultsKeyHeatMap;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
