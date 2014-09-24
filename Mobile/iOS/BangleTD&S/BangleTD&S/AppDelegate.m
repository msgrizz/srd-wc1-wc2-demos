//
//  AppDelegate.m
//  BangleTD&S
//
//  Created by Morgan Davis on 6/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import "PLTDevice.h"
#import "PLTDevice_Bangle.h"
#import "BRSubscribeToServiceCommand.h"


@interface AppDelegate () <PLTDeviceSubscriber>

- (void)registerForDeviceNotifications;
- (void)newDeviceAvailableNotification:(NSNotification *)notification;
- (void)didOpenDeviceConnectionNotification:(NSNotification *)notification;
- (void)didFailToOpenDeviceConnectionNotification:(NSNotification *)notification;
- (void)deviceDidDisconnectNotification:(NSNotification *)notification;
- (void)subscribeToInfo;

@property(nonatomic,strong,readwrite)	PLTDevice		*device;

@end


@implementation AppDelegate
            
#pragma mark - Private

- (void)registerForDeviceNotifications
{
	// since PLTDevice lets us know when connection-related events occur via NSNotifications, we must register to receive them.
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(newDeviceAvailableNotification:)
												 name:PLTDeviceAvailableNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didOpenDeviceConnectionNotification:)
												 name:PLTDeviceDidOpenConnectionNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didFailToOpenDeviceConnectionNotification:)
												 name:PLTDeviceDidFailOpenConnectionNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceDidDisconnectNotification:)
												 name:PLTDeviceDidCloseConnectionNotification object:nil];
}

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	// a new device has been detected. if we don't already have an open connection to another device, open a connection with the new device.
	
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNotificationKey];
		[self.device openConnection];
	}
}

- (void)didOpenDeviceConnectionNotification:(NSNotification *)notification
{
	// now that a connection to the device had been established, let PTLDevice know what info we're interested in receiving.
	
	NSLog(@"didOpenDeviceConnectionNotification: %@", notification.userInfo[PLTDeviceNotificationKey]);
	
	//[self subscribeToInfo];
}

- (void)didFailToOpenDeviceConnectionNotification:(NSNotification *)notification
{
	NSLog(@"didFailToOpenDeviceConnectionNotification: %@ error: %@", 
		  notification.userInfo[PLTDeviceNotificationKey], notification.userInfo[PLTDeviceConnectionErrorNotificationKey]);
	
	self.device = nil;
}

- (void)deviceDidDisconnectNotification:(NSNotification *)notification
{
	NSLog(@"deviceDidDisconnectNotification: %@", notification.userInfo[PLTDeviceNotificationKey]);
	
	self.device = nil;
}

- (void)subscribeToInfo
{
	NSLog(@"subscribeToInfo");
	
	NSError *err = [self.device subscribe:self	toService:(PLTService)PLTServiceAmbientHumidity			withMode:PLTSubscriptionModePeriodic	andPeriod:100];
	if (err) NSLog(@"Error: %@", err);
	err = [self.device subscribe:self			toService:(PLTService)PLTServiceAmbientPressure			withMode:PLTSubscriptionModePeriodic	andPeriod:100];
	if (err) NSLog(@"Error: %@", err);
	err = [self.device subscribe:self			toService:(PLTService)PLTServiceSkinTemperature			withMode:PLTSubscriptionModePeriodic	andPeriod:100];
	if (err) NSLog(@"Error: %@", err);
//	NSError *err = [self.device subscribe:self			toService:(PLTService)PLTServiceOrientationTracking		withMode:PLTSubscriptionModePeriodic	andPeriod:50];
//	if (err) NSLog(@"Error: %@", err);
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"AppDelegate:PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	printf(".");
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self registerForDeviceNotifications];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device not Found"
														message:@"Bandle could not be found. Please re-pair the device and try again."
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
