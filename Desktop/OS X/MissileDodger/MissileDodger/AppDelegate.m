//
//  AppDelegate.m
//  MissileDodger
//
//  Created by Davis, Morgan on 11/16/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MissileWindowController.h"


@interface AppDelegate ()

@property(nonatomic, retain) IBOutlet MissileWindowController *missileWindowController;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.missileWindowController.window center];
    [self.missileWindowController showWindow:self];
}

@end
