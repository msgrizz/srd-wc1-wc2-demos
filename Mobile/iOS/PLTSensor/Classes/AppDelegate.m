//
//  CSR_Wireless_SensorAppDelegate.m
//  CSR Wireless Sensor
//
//  Copyright Cambridge Silicon Radio Ltd 2009. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SettingsViewController.h"
#import <Foundation/Foundation.h>
#import "PLT3DViewController.h"
#import "SensorsViewController.h"
#import "StreetView2ViewController.h"
#import "LocationMonitor.h"
#import "PLTDeviceHandler.h"
#import "PLTContextServer.h"
#import "NSData+Base64.h"
#import "SettingsNavigationController.h"
#import "BRKStageViewController.h"
#import "UIDevice+ScreenSize.h"
#import "TestFlight.h"


#define MAX_PACKET_ROADCAST_RATE        20.0 // Hz
#define GOOGLE_API_KEY                  @"AIzaSyDbFPnLMLK5S5nwl9L6gD6gyNi3XhVmkr4"

NSString *const PLTDefaultsKeyDefaultsVersion =								@"DefaultsVersion";
NSString *const PLTDefaultsKeyContextServerAddress =                        @"ContextServerAddress";
NSString *const PLTDefaultsKeyContextServerPort =                           @"ContextServerPort";
NSString *const PLTDefaultsKeyContextServerSecureSockets =                  @"ContextServerSecureSockets";
NSString *const PLTDefaultsKeyContextServerUsername =                       @"ContextServerUsername";
NSString *const PLTDefaultsKeyContextServerPassword =                       @"ContextServerPassword";
NSString *const PLTDefaultsKeyContextServerAutoConnect =                    @"ContextServerAutoConnect";
NSString *const PLTDefaultsKeyContextServerAutoRegister =                   @"ContextServerAutoRegister";
NSString *const PLTDefaultsKeyShowStatusIcons =								@"ShowStatusIcons";
NSString *const PLTDefaultsKeyMetricUnits =									@"MetricUnits";
NSString *const PLTDefaultsKeyOverrideLocations =							@"OverrideLocations";
    NSString *const PLTDefaultsKeyOverrideLocationLabel =										@"Label";
	NSString *const PLTDefaultsKeyOverrideLocationLatitude =									@"Latitude";
    NSString *const PLTDefaultsKeyOverrideLocationLongitude =									@"Longitude";
	NSString *const PLTDefaultsKeyOverrideLocationStreetViewPrecacheRoundingMultiple =			@"StreetViewPrecacheRoundingMultiple";
	NSString *const PLTDefaultsKeyOverrideLocationAskedPrecacheStreetViewRoundingMultiple =		@"AskedPrecacheStreetViewRoundingMultiple";
NSString *const PLTDefaultsKeyOverrideSelectedLocation =					@"SelectedOverrideLocation";
NSString *const PLTDefaultsKeyGestureRecognition =							@"GestureRecognition";
NSString *const PLTDefaultsKey3DHeadMirrorImage =							@"3DHeadMirrorImage";
NSString *const PLTDefaultsKey3DHeadDebugOverlay =                          @"3DHeadDebugOverlay";
NSString *const PLTDefaultsKeyStreetViewInfoOverlay =                       @"StreetViewInfoOverlay";
NSString *const PLTDefaultsKeyStreetViewDebugOverlay =                      @"StreetViewDebugOverlay";
NSString *const PLTDefaultsKeyStreetViewRoundingMultiple =                  @"StreetViewRoundingMultiple";
NSString *const PLTDefaultsKeyTemperatureOffsetCelcius =					@"TemperatureOffsetCelcius";
NSString *const PLTDefaultsKeySendOldSkewlEvents =							@"SendOldSkewlEvents";
NSString *const PLTDefaultsKeyHeadTrackingCalibrationTriggers =				@"HeadTrackingCalibrationTriggers";


@interface AppDelegate () <UIApplicationDelegate, UIPopoverControllerDelegate, PLTContextServerDelegate, LocationMonitorDelegate, SettingsViewControllerDelegate>

- (void)registerDefaults;
- (BOOL)checkAutoConnectToContextServer;
- (void)sendPacketToContextServer:(NSData *)packetData;
//- (void)sendInfoToContextServer:(NSDictionary *)info;
//- (void)sendOldSkewlInfoToContextServer:(NSData *)packetData;
//- (void)sendHeadTrackingCalibrationToServer:(NSData *)calPacketData; // "original" implementation
//- (void)sendHeadTrackingCalibrationToServer:(Vec4)calQuaternion;
- (void)headsetDidConnectNotification:(NSNotification *)note;
- (void)headsetInfoDidUpdateNotification:(NSNotification *)note;
- (void)headsetHeadTrackingCalibrationDidUpdateNotification:(NSNotification *)note;

@property(nonatomic,retain) SettingsViewController      *settingsViewController;
@property(nonatomic,retain) PLT3DViewController         *threeDViewController;
@property(nonatomic,retain) SensorsViewController       *sensorsViewController;
@property(nonatomic,retain) StreetView2ViewController   *streetView2ViewController;
@property(nonatomic,retain) BRKStageViewController      *gameViewController;
@property(strong,nonatomic) UITabBarController          *tabBarController;
@property(nonatomic,strong) NSDate                      *lastPacketBroadcastDate;
@property(nonatomic,strong) UIPopoverController         *settingsPopoverController;

@end


@implementation AppDelegate

#pragma mark - Public

- (void)connectToContextServer
{
    NSString *address = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerAddress];
    NSString *port = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPort];
    NSString *username = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerUsername];
    NSString *password = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPassword];
    BOOL secure = [DEFAULTS boolForKey:PLTDefaultsKeyContextServerSecureSockets];
    
    NSMutableString *urlstring = [NSString stringWithFormat:@"%@://%@:%@/context-server/context-websocket", (secure ? @"wss" : @"ws"), address, port];
	PLTContextServer *server = [PLTContextServer sharedContextServerWithURL:urlstring
													 username:username
													 password:password
													protocols:@[@"plt-device"]];
	[server openConnection];
}

- (void)registerDeviceWithContextServer
{
    NSLog(@"registerDeviceWithContextServer");
    
    NSDictionary *subpayload = @{@"deviceId" : [[UIDevice currentDevice].identifierForVendor UUIDString],
								 @"vendorId" : @"1151",
								 @"productId" : @"1045",
								 @"versionNumber" : @"2116",
								 @"productName" : @"Plantronics BT300",
								 @"internalName" : @"Vpro1",
								 @"manufacturerName" : @"Plantronics"};
    
    NSDictionary *payload = @{@"device" : subpayload};
    
    PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_REGISTER_DEVICE messageId:REGISTER_DEVICE payload:payload];
    [[PLTContextServer sharedContextServer] sendMessage:message cacheIfServerIsOffline:YES];
}

- (BOOL)hasServerCredentials
{
	NSString *username = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerUsername];
	NSString *password = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPassword];
	
	if ([username length] && [password length]) return YES;
	return NO;
}

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
	[DEFAULTS setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:PLTDefaultsKeyDefaultsVersion];
	[DEFAULTS synchronize];
}

- (BOOL)checkAutoConnectToContextServer
{
	NSLog(@"checkAutoConnectToContextServer");
	BOOL autoConnect = [DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoConnect];
	BOOL autoRegister = [DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoRegister];

	if ([self hasServerCredentials]) {
		
		if (autoConnect && !CLIENT_AUTHENTICATED) {
			[[PLTContextServer sharedContextServer] addDelegate:self];
			[self connectToContextServer];
			return YES;
		}
		else if (autoConnect && CLIENT_AUTHENTICATED && autoRegister && !DEVICE_REGISTERED) {
			[[PLTContextServer sharedContextServer] addDelegate:self];
			[self registerDeviceWithContextServer];
			return YES;
		}
	}
	
	return NO;
}

- (void)sendPacketToContextServer:(NSData *)packetData
{
    NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:self.lastPacketBroadcastDate];
    if ( !self.lastPacketBroadcastDate || (gap > (1.0/MAX_PACKET_ROADCAST_RATE)) ) {
        
        NSDictionary *payload = @{@"quaternion" : [packetData base64EncodedString],
								  @"isTransient" : @"true"};
		PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_EVENT messageId:EVENT_HEAD_TRACKING
                                                                                deviceId:[[UIDevice currentDevice].identifierForVendor UUIDString]
																				 payload:payload
																				location:[LocationMonitor sharedMonitor].location];
		
        [[PLTContextServer sharedContextServer] sendMessage:message cacheIfServerIsOffline:YES];
		//NSLog(@"message: %@",[message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]);
        self.lastPacketBroadcastDate = [NSDate date];
    }
}

//// this is the "original" implementation that should work...
//- (void)sendHeadTrackingCalibrationToServer:(NSData *)calPacketData
//{
//	NSLog(@"sendHeadTrackingCalibrationToServer:");
//	
//	NSData *packetData = calPacketData;
//	NSDictionary *payload = @{@"quaternion" : [packetData base64EncodedString]};
//	PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_COMMAND
//																		   messageId:SET_CALIBRATION
//																			deviceId:[[UIDevice currentDevice].identifierForVendor UUIDString]
//																			 payload:payload
//																			location:nil];
//	
//	[[PLTContextServer sharedContextServer] sendMessage:message cacheIfServerIsOffline:YES];
//}

//- (void)sendHeadTrackingCalibrationToServer:(Vec4)calQuaternion
//{
//	NSLog(@"sendHeadTrackingCalibrationToServer:");
//	
//	// this is pretty inconvenient... get a packet over MFi wire, decode it, apply cal (now we have a Vec4),
//	// then RE-PACK it to look like an MFi packet (with header and all). this should be changed.
//	
////	const int pLen = 22;
////	
////	uint8_t packet[pLen];
////	memset(&packet, 0, pLen);
////	//packet[0] =
////	
////	uint16_t quaternion[8];
////	memset(&quaternion, 0, 8);
////
////	quaternion[0] = (uint16_t)lround(calQuaternion.x * 16384.0f);
////	quaternion[1] = (uint16_t)lround(calQuaternion.y * 16384.0f);
////	quaternion[2] = (uint16_t)lround(calQuaternion.z * 16384.0f);
////	quaternion[3] = (uint16_t)lround(calQuaternion.w * 16384.0f);
////	
////	packet[2] = (uint8_t)(quaternion[0] >> 8);
////	packet[3] = (uint8_t)(quaternion[0]);
////	packet[6] = (uint8_t)(quaternion[1] >> 8);
////	packet[7] = (uint8_t)(quaternion[1]);
////	packet[10] = (uint8_t)(quaternion[2] >> 8);
////	packet[11] = (uint8_t)(quaternion[2]);
////	packet[14] = (uint8_t)(quaternion[3] >> 8);
////	packet[15] = (uint8_t)(quaternion[3]);
////	
////	NSData *packetData = [NSData dataWithBytes:&packet length:pLen];
//
//
//	//NSLog(@"message: %@",[message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]);
//}

//- (void)sendOldSkewlInfoToContextServer:(NSData *)packetData
//{
//	CLLocation *location = [LocationMonitor sharedMonitor].location;
//	NSString *packetString = [packetData base64EncodedString];
//	NSDictionary *payload = @{@"quaternion" : packetString,
//						   @"isTransient" : @"true"};
//	PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_EVENT messageId:EVENT_HEAD_TRACKING
//																			deviceId:@"" payload:payload location:location];
//	
//	[[PLTContextServer sharedContextServer] sendMessage:message cacheIfServerIsOffline:YES];
//}

- (void)headsetDidConnectNotification:(NSNotification *)note
{
	if (HEADSET_CONNECTED) [self checkAutoConnectToContextServer];
}

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
//    if (DEVICE_REGISTERED) {
//		//[self sendInfoToContextServer:[note userInfo]];
//		//[self sendPacketToContextServer:[note userInfo][PLTHeadsetInfoKeyPacketData]];
//		[self sendPacketToContextServer:[note userInfo][PLTHeadsetInfoKeyCalibratedPacketData]];
//    }
}

- (void)headsetHeadTrackingCalibrationDidUpdateNotification:(NSNotification *)note
{
	if (DEVICE_REGISTERED) {
//		NSData *calQuaternionData = [note userInfo][PLTHeadsetHeadTrackingKeyCalibrationPacket];
//		Vec4 calQuaternion;
//		[calQuaternionData getBytes:&calQuaternion length:[calQuaternionData length]];
//		[self sendHeadTrackingCalibrationToServer:calQuaternion];
		
		// "original" implementation that should work...
		//[self sendHeadTrackingCalibrationToServer:[note userInfo][PLTHeadsetHeadTrackingKeyCalibrationPacket]];
	}
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerDefaults];
    
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    //[TestFlight takeOff:@"3b9e359c-4aa7-4f77-aefd-8d2ee925475e"]; // ORIGINAL APP TOKEN
	[TestFlight takeOff:@"df5ad1e2-ee16-4df9-b683-bfcab4dc3c75"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.threeDViewController = [[PLT3DViewController alloc] initWithNibName:nil bundle:nil];
	self.sensorsViewController = [[SensorsViewController alloc] initWithNibName:nil bundle:nil];
    //self.streetViewViewController = [[StreetViewViewController alloc] initWithNibName:nil bundle:nil];
    self.streetView2ViewController = [[StreetView2ViewController alloc] initWithNibName:nil bundle:nil];
    self.gameViewController = [[BRKStageViewController alloc] initWithNibName:nil bundle:nil];
    self.settingsViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    self.settingsViewController.delegate = self;
    
    self.tabBarController = [[UITabBarController alloc] init];
    NSMutableArray *viewControllers = [@[[[UINavigationController alloc] initWithRootViewController:self.sensorsViewController],
                                        [[UINavigationController alloc] initWithRootViewController:self.threeDViewController],
                                        //[[UINavigationController alloc] initWithRootViewController:self.streetViewViewController],
                                        [[UINavigationController alloc] initWithRootViewController:self.streetView2ViewController]] mutableCopy];
    if ((IPHONE5 || IPAD) && IOS7) {
        [viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:self.gameViewController]];
    }
	self.tabBarController.viewControllers = viewControllers;
    self.window.rootViewController = self.tabBarController;
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0 green:(33.0/256.0) blue:(66.0/256.0) alpha:1.0]];
	
	if (OS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}

    [LocationMonitor sharedMonitor].delegate = self;
    [[LocationMonitor sharedMonitor] startUpdatingLocation];
    [[PLTDeviceHandler sharedHandler] setHeadTrackingCalibrationTriggers:[[DEFAULTS objectForKey:PLTDefaultsKeyHeadTrackingCalibrationTriggers] unsignedIntegerValue]];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//	[nc addObserver:self selector:@selector(headsetDidConnectNotification:) name:PLTHeadsetDidConnectNotification object:nil];
//    [nc addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
//	[nc addObserver:self selector:@selector(headsetHeadTrackingCalibrationDidUpdateNotification:) name:PLTHeadsetHeadTrackingCalibrationDidUpdateNotification object:nil];

	[self checkAutoConnectToContextServer];
	
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [DEFAULTS synchronize];
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didAuthenticate:(BOOL)authenticationWasSuccessful
{
	NSLog(@"didAuthenticate: %@",(authenticationWasSuccessful?@"YES":@"NO"));
	if ([DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoRegister] && ([PLTContextServer sharedContextServer].state < PLT_CONTEXT_SERVER_REGISTERING) && [self hasServerCredentials]) {
		[self registerDeviceWithContextServer];
	}
	else {
		//[[PLTContextServer sharedContextServer] removeDelegate:self];
	}
}

- (void)server:(PLTContextServer *)sender didRegister:(BOOL)registrationWasSuccessful
{
	NSLog(@"registrationWasSuccessful");
	//[[PLTContextServer sharedContextServer] removeDelegate:self];
}

- (void)server:(PLTContextServer *)sender didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
	NSLog(@"didCloseWithCode");
	//[[PLTContextServer sharedContextServer] removeDelegate:self];
}

- (void)server:(PLTContextServer *)sender didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError");
	//[[PLTContextServer sharedContextServer] removeDelegate:self];
}

- (BOOL)serverShouldTryToReconnect:(PLTContextServer *)sender
{
	NSLog(@"serverShouldTryToReconnect:");
	return [self hasServerCredentials];
}

#pragma mark - LocationMonitorDelegate

- (CLLocation *)locationMonitor:(LocationMonitor *)monitor overrideAtLocation:(CLLocation *)realLocation
{
	PLTContextServerMessage *message = [PLTContextServer sharedContextServer].latestMessage;
	NSString *selectedLabel = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
	BOOL override = [selectedLabel isEqualToString:@"__none"];
	
	if (HEADSET_CONNECTED && !override) {
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
	else if (!HEADSET_CONNECTED && [message.type isEqualToString:MESSAGE_TYPE_EVENT]) {
		return message.location;
	}
	
    return nil;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[DEFAULTS synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTSettingsPopoverDidDismissNotification object:nil];
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

//- (void)settingsViewControllerDidClickStreetViewPrecache:(SettingsViewController *)theController
//{
//    self.tabBarController.selectedIndex = 2;
//    StreetViewViewController *controller = ((UINavigationController *)self.tabBarController.viewControllers[2]).viewControllers[0];
//    
//    if (self.settingsPopoverController) {
//		[self.settingsPopoverController dismissPopoverAnimated:YES];
//	}
//	else {
//		[self.tabBarController.selectedViewController dismissViewControllerAnimated:YES completion:nil];
//	}
//	
//    [controller precache];
//}

- (UIPopoverController *)popoverControllerForSettingsViewController:(SettingsViewController *)theController
{
	return self.settingsPopoverController;
}

@end
