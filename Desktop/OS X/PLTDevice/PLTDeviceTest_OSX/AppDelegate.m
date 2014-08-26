//
//  AppDelegate.m
//  PLTDeviceTest
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "PLTDLog.h"


@interface AppDelegate ()

@property(nonatomic,strong) MainWindowController *mainWindowController;

@end


@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_pltDLogLevel = DLogLevelTrace;
    self.mainWindowController = [[MainWindowController alloc] init];
    [self.mainWindowController showWindow:self];
}

@end
