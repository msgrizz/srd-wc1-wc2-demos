//
//  AppDelegate.m
//  WC2 Kit
//
//  Created by Morgan Davis on 12/30/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SettingsViewController.h"
#import <Foundation/Foundation.h>
#import "HeadViewController.h"
#import "SensorsViewController.h"
#import "StreetViewViewController.h"
#import "KubiViewController.h"
//#import "SecurityViewController.h"
#import "Security3DViewController.h"
#import "VoiceViewController.h"
#import "LocationMonitor.h"
#import "PLTDeviceHelper.h"
#import "SettingsNavigationController.h"
#import "BRKStageViewController.h"
#import "UIDevice+ScreenSize.h"
#import "TestFlight.h"


@interface PLTDLogger : NSObject
+ (PLTDLogger *)sharedLogger;
@property(nonatomic,assign)	NSInteger	level;
@end


#define GOOGLE_API_KEY                  @"AIzaSyDbFPnLMLK5S5nwl9L6gD6gyNi3XhVmkr4"
#define TESTFLIGHT_APP_TOKEN			@"caff2a7f-7b53-4240-a653-f22fa96d13ab"


NSString *const PLTDefaultsKeySettingsInitialized =							@"SettingsInitialized";
NSString *const PLTDefaultsKeyDefaultsVersion =								@"DefaultsVersion";
NSString *const PLTDefaultsKeyMetricUnits =									@"MetricUnits";
NSString *const PLTDefaultsKeyOverrideLocations =							@"OverrideLocations";
NSString *const PLTDefaultsKeyOverrideLocationLabel =										@"Label";
NSString *const PLTDefaultsKeyOverrideLocationLatitude =									@"Latitude";
NSString *const PLTDefaultsKeyOverrideLocationLongitude =									@"Longitude";
NSString *const PLTDefaultsKeyOverrideLocationStreetViewPrecacheRoundingMultiple =			@"StreetViewPrecacheRoundingMultiple";
NSString *const PLTDefaultsKeyOverrideLocationAskedPrecacheStreetViewRoundingMultiple =		@"AskedPrecacheStreetViewRoundingMultiple";
NSString *const PLTDefaultsKeyOverrideSelectedLocation =					@"SelectedOverrideLocation";
NSString *const PLTDefaultsKeyHeadGestureRecognition =						@"HeadGestureRecognition";
NSString *const PLTDefaultsKeyHeadMirrorImage =								@"HeadMirrorImage";
NSString *const PLTDefaultsKeyHTCalibrationTriggers =						@"HTCalibrationTriggers";
//NSString *const PLTDefaultsKeySecurityEnabled =								@"SecurityEnabled";
NSString *const PLTDefaultsKeySecurityDevice =								@"SecurityDevice";
NSString *const PLTDefaultsKeySecurityDeviceName =										@"SecurityDeviceName";
NSString *const PLTDefaultsKeySecurityDeviceID =										@"SecurityDeviceID";
NSString *const PLTDefaultsKeySecurityFIDOUsername =									@"SecurityFIDOUsername";
NSString *const PLTDefaultsKeyKubiEnabled =									@"KubiEnabled";
NSString *const PLTDefaultsKeyKubiDevice =									@"KubiDevice";
NSString *const PLTDefaultsKeyKubiDeviceName =											@"KubiDeviceName";
NSString *const PLTDefaultsKeyKubiDeviceTokBoxAPIKey =									@"KubiDeviceTokBoxAPIKey";
NSString *const PLTDefaultsKeyKubiDeviceTokBoxSessionID =								@"KubiDeviceTokBoxSessionID";
NSString *const PLTDefaultsKeyKubiDeviceTokBoxPublisherIDiPad =							@"KubiDeviceTokBoxPublisherIDiPad";
NSString *const PLTDefaultsKeyKubiMode =									@"KubiMode";
NSString *const PLTDefaultsKeyKubiMirror =									@"KubiMirror";


@interface AppDelegate () <UIApplicationDelegate, UIPopoverControllerDelegate, LocationMonitorDelegate, SettingsViewControllerDelegate>

- (void)registerDefaults;
- (void)securityEnabledChangedNotification:(NSNotification *)aNotification;
- (void)kubiEnabledChangedNotification:(NSNotification *)aNotification;

@property(nonatomic,retain) SettingsViewController      *settingsViewController;
@property(nonatomic,retain) HeadViewController			*headViewController;
@property(nonatomic,retain) SensorsViewController       *sensorsViewController;
@property(nonatomic,retain) StreetViewViewController	*streetViewViewController;
@property(nonatomic,retain) BRKStageViewController      *gameViewController;
@property(nonatomic,retain) KubiViewController			*kubiViewController;
//@property(nonatomic,retain) SecurityViewController		*securityViewController;
@property(nonatomic,retain) Security3DViewController	*security3DViewController;
@property(nonatomic,retain) VoiceViewController			*voiceViewController;
@property(strong,nonatomic) UITabBarController          *tabBarController;
@property(nonatomic,strong) NSDate                      *lastPacketBroadcastDate;
@property(nonatomic,strong) UIPopoverController         *settingsPopoverController;

@end


@implementation AppDelegate

#pragma mark - Public

- (void)settingsButton:(id)sender
{
	SettingsNavigationController *navController = [[SettingsNavigationController alloc] initWithRootViewController:self.settingsViewController];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[self.tabBarController.selectedViewController presentViewController:navController animated:YES completion:nil];
	}
	else {
		if (self.settingsPopoverController.popoverVisible) {
			[self.settingsPopoverController dismissPopoverAnimated:YES];
		}
		else {
			self.settingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
			self.settingsPopoverController.delegate = self;
			[self.settingsPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
	}
}

#pragma mark - Private

- (void)registerDefaults
{
	if (![DEFAULTS boolForKey:PLTDefaultsKeySettingsInitialized]) {
		NSLog(@"Initializing defaults.");
		// if this is the first time the application has run, read
		// the default application settings from PLTAppSettings.plist
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *settingsFilePath = [mainBundle pathForResource:@"DefaultSettings" ofType:@"plist"];
		NSDictionary *defaultSettings = [NSDictionary dictionaryWithContentsOfFile:settingsFilePath];
		[DEFAULTS registerDefaults:defaultSettings];
	}
	
	// do version upgrade stuff here in the future
	NSString *previousVersion = [DEFAULTS objectForKey:PLTDefaultsKeyDefaultsVersion];
	NSLog(@"Previously used version: %@",previousVersion);
	[DEFAULTS setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:PLTDefaultsKeyDefaultsVersion];
	[DEFAULTS synchronize];
}

//- (void)securityEnabledChangedNotification:(NSNotification *)aNotification
//{
//	NSMutableArray *controllers = [self.tabBarController.viewControllers mutableCopy];
//	if ([DEFAULTS boolForKey:PLTDefaultsKeySecurityEnabled]) {
//		if ([controllers lastObject] == self.kubiViewController.navigationController) {
//			[controllers insertObject:[[UINavigationController alloc] initWithRootViewController:self.securityViewController] atIndex:[controllers count]-1]; // insert before Kubi
//		}
//		else {
//			[controllers addObject:[[UINavigationController alloc] initWithRootViewController:self.securityViewController]];
//		}
//	}
//	else {
//		[controllers removeObject:self.securityViewController.navigationController];
//	}
//	[self.tabBarController setViewControllers:controllers animated:YES];
//}

- (void)kubiEnabledChangedNotification:(NSNotification *)aNotification
{
	NSMutableArray *controllers = [self.tabBarController.viewControllers mutableCopy];
	if ([DEFAULTS boolForKey:PLTDefaultsKeyKubiEnabled]) {
		[controllers addObject:[[UINavigationController alloc] initWithRootViewController:self.kubiViewController]]; // insert last
	}
	else {
		[controllers removeObject:self.kubiViewController.navigationController];
	}
	[self.tabBarController setViewControllers:controllers animated:YES];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[PLTDLogger sharedLogger].level = 0;
	
	[self registerDefaults];
	
	[GMSServices provideAPIKey:GOOGLE_API_KEY];
	[TestFlight takeOff:TESTFLIGHT_APP_TOKEN];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.headViewController = [[HeadViewController alloc] initWithNibName:nil bundle:nil];
	self.sensorsViewController = [[SensorsViewController alloc] initWithNibName:nil bundle:nil];
	self.streetViewViewController = [[StreetViewViewController alloc] initWithNibName:nil bundle:nil];
	self.gameViewController = [[BRKStageViewController alloc] initWithNibName:nil bundle:nil];
	//self.securityViewController = [[SecurityViewController alloc] initWithNibName:nil bundle:nil];
	self.security3DViewController = [[Security3DViewController alloc] initWithNibName:nil bundle:nil];
	self.kubiViewController = [[KubiViewController alloc] initWithNibName:nil bundle:nil];
	self.voiceViewController = [[VoiceViewController alloc] initWithNibName:nil bundle:nil];
	self.settingsViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
	self.settingsViewController.delegate = self;
	
	self.tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *viewControllers = [@[[[UINavigationController alloc] initWithRootViewController:self.sensorsViewController],
										 [[UINavigationController alloc] initWithRootViewController:self.headViewController],
										 [[UINavigationController alloc] initWithRootViewController:self.streetViewViewController],
										[[UINavigationController alloc] initWithRootViewController:self. security3DViewController],
										 [[UINavigationController alloc] initWithRootViewController:self.voiceViewController]] mutableCopy];
	
//	if (IPHONE5 || IPAD) {
//		[viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:self.gameViewController]];
//	}
	
//	if ([DEFAULTS boolForKey:PLTDefaultsKeySecurityEnabled]) {
//		[viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:self.securityViewController]];
//	}
	
	if ([DEFAULTS boolForKey:PLTDefaultsKeyKubiEnabled]) {
		[viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:self.kubiViewController]];
	}
	
	self.tabBarController.viewControllers = viewControllers;
	self.window.rootViewController = self.tabBarController;
	
	[[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

	[LocationMonitor sharedMonitor].delegate = self;
	[[LocationMonitor sharedMonitor] startUpdatingLocation];
	[[PLTDeviceHelper sharedHelper] setHeadTrackingCalibrationTriggers:[[DEFAULTS objectForKey:PLTDefaultsKeyHTCalibrationTriggers] unsignedIntegerValue]];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//	[nc addObserver:self selector:@selector(securityEnabledChangedNotification:) name:PLTSettingsSecurityEnabledChangedNotification object:nil];
	[nc addObserver:self selector:@selector(kubiEnabledChangedNotification:) name:PLTSettingsKubiEnabledChangedNotification object:nil];

	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[DEFAULTS synchronize];
}

#pragma mark - LocationMonitorDelegate

- (CLLocation *)locationMonitor:(LocationMonitor *)monitor overrideAtLocation:(CLLocation *)realLocation
{
	NSString *selectedLabel = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
	BOOL override = ![selectedLabel isEqualToString:@"__none"];
	
	if (override) {
		NSDictionary *location = nil;
		for (NSDictionary *l in (NSArray *)[DEFAULTS objectForKey:PLTDefaultsKeyOverrideLocations]) {
			NSString *label = l[PLTDefaultsKeyOverrideLocationLabel];
			if ([label isEqualToString:selectedLabel]) {
				location = l;
				break;
			}
		}
		if (location) {
			CLLocationDegrees lat = [location[PLTDefaultsKeyOverrideLocationLatitude] doubleValue];
			CLLocationDegrees lng = [location[PLTDefaultsKeyOverrideLocationLongitude] doubleValue];
			return [[CLLocation alloc] initWithLatitude:lat longitude:lng];
		}
		else { 
			//NSLog(@"*** Error: no location \"%@\" found.",selectedLabel);
		}
	}
	return nil;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[DEFAULTS synchronize];
}

#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewControllerDidEnd:(SettingsViewController *)theController
{
	if (self.settingsPopoverController) {
		[self.settingsPopoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.tabBarController.selectedViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (UIPopoverController *)popoverControllerForSettingsViewController:(SettingsViewController *)theController
{
	return self.settingsPopoverController;
}

@end
