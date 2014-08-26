//
//  AppDelegate.m
//  PLTDeviceTest_IOS
//
//  Created by Morgan Davis on 5/29/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import "PLTDLog.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	_pltDLogLevel = DLogLevelTrace;
    return YES;
}

@end
