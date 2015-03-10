//
//  AppDelegate.m
//  BRDeviceTest_IOS
//
//  Created by Morgan Davis on 5/29/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import "PLTDLog.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[PLTDLogger sharedLogger].level = DLogLevelTrace;
    return YES;
}

@end
