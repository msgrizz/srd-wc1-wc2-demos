//
//  AppDelegate.h
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define DEFAULTS    [NSUserDefaults standardUserDefaults]


extern NSString *const PLTDefaultsKeyDefaultsVersion;
extern NSString *const PLTDefaultsKeyContextServerAddress;
extern NSString *const PLTDefaultsKeyContextServerPort;
extern NSString *const PLTDefaultsKeyContextServerUsername;
extern NSString *const PLTDefaultsKeyContextServerPassword;
extern NSString *const PLTDefaultsKeyContextServerAutoConnect;
extern NSString *const PLTDefaultsKeyVideoSwitchAutoConnect;
extern NSString *const PLTDefaultsKeyCam1Location;
extern NSString *const PLTDefaultsKeyCam2Location;
extern NSString *const PLTDefaultsKeyCam3Location;
extern NSString *const PLTDefaultsKeyCamSwitchDelay;


@class MainWindowController;
@class SettingsWindowController;


@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)connectToContextServer;
- (BOOL)hasServerCredentials;

@property (assign) IBOutlet MainWindowController *mainWindowController;
@property (retain) SettingsWindowController *settingsWindowController;

@end
