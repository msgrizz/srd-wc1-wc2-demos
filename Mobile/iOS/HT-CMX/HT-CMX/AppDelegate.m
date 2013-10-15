//
//  AppDelegate.m
//  HT-CMX
//
//  Created by Davis, Morgan on 10/7/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"


NSString *const PLTDefaultsKeyDefaultsVersion =			@"DefaultsVersion";
NSString *const PLTDefaultsKeyHTSensitivity =			@"HTSensitivity";
NSString *const PLTDefaultsKeyImage =					@"Image";


@interface AppDelegate()
	
- (void)registerDefaults;

@property(nonatomic, strong) ViewController *viewController;

@end


@implementation AppDelegate
	
#pragma mark - Private

- (void)registerDefaults
{
	if (![DEFAULTS boolForKey:@"SettingsAreInitialized"]) {
		NSLog(@"Initializing defaults.");
		// if this is the first time the application has run, read
		// the default application settings from PLTAppSettings.plist
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *settingsFilePath = [mainBundle pathForResource:@"PLTAppSettings" ofType:@"plist"];
		NSDictionary *defaultSettings = [NSDictionary dictionaryWithContentsOfFile:settingsFilePath];
		[DEFAULTS registerDefaults:defaultSettings];
	}
	
	// do version upgrade stuff here in the future
	NSString *previousVersion = [DEFAULTS objectForKey:PLTDefaultsKeyDefaultsVersion];
	NSLog(@"Previously used version: %@",previousVersion);
	[DEFAULTS setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:PLTDefaultsKeyDefaultsVersion];
	[DEFAULTS synchronize];
}
	
#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self registerDefaults];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.viewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
