//
//  StreetViewViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 2/5/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//


#import "StreetViewViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "PLTContextServer.h"
#import "PLTDeviceHandler.h"
#import "LocationMonitor.h"
#import "NSData+Base64.h"
//#import "TestFlight.h"
#import "Reachability.h"
#import "LocationOverrideViewController.h"
#import "PLTDevice.h"


#define CAMERA_FOV						80.0
#define COORD_SEARCH_RADIUS             100.0 // meters


@interface StreetViewViewController () <PLTDeviceSubscriber, PLTContextServerDelegate, GMSPanoramaViewDelegate>

//- (void)headsetInfoDidUpdateNotification:(NSNotification *)note;
//- (void)headsetInfoDidUpdate:(NSDictionary *)info;


- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;


@property(nonatomic,strong) GMSPanoramaView     *panoramaView;
@property(nonatomic,assign) BOOL                panoramaConfigured;
@property(nonatomic,strong) Reachability        *reachability;
@property(nonatomic,strong) UIImageView         *reachabilityImageView;

@end


@implementation StreetViewViewController

#pragma mark - Private

- (void)locationButton:(id)sender
{
    CLLocationCoordinate2D location = [LocationMonitor sharedMonitor].location.coordinate;
    [self.panoramaView moveNearCoordinate:location radius:COORD_SEARCH_RADIUS];
}

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self subscribeToServices];
}

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (CONNECTED_DEVICE) {
		NSError *err = nil;
		
//		[d subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
//		
//		[d subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to proximity service: %@", err);
		
		[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
		
//		[d subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to pedometer service: %@", err);
//		
//		[d subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to free fall service: %@", err);
//		
//		[d subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to taps service: %@", err);
//		
//		[d subscribe:self toService:PLTServiceMagnetometerCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to magnetometer calibration service: %@", err);
//		
//		[d subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to hyroscope calibration service: %@", err);
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (void)unsubscribeFromServices
{
	NSLog(@"unsubscribeFromServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (CONNECTED_DEVICE) {
		[d unsubscribeFromAll:self];
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (void)locationOverrideDidSelectNewLocationNotification:(NSDictionary *)info
{
    [self locationButton:self];
}

- (BOOL)checkReachability
{
    NetworkStatus status = [self.reachability currentReachabilityStatus];
                            
    if (status==ReachableViaWiFi || status==ReachableViaWWAN) {
        self.reachabilityImageView.alpha = 0.0;
        return YES;
    }
    else {
        //[self.panoramaView moveNearCoordinate:CLLocationCoordinate2DMake(37.623304, -122.976724)]; // out in the SF bay
        self.reachabilityImageView.alpha = 1.0;
    }
    return NO;
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		//NSData *rotationVectorData = info[PLTHeadsetInfoKeyRotationVectorData];
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
		Vec3 rotationVector = (Vec3){-eulerAngles.x, eulerAngles.y, eulerAngles.z};
		//[rotationVectorData getBytes:&rotationVector length:[rotationVectorData length]];
		GMSPanoramaCamera *camera = [GMSPanoramaCamera cameraWithHeading:rotationVector.x pitch:rotationVector.y zoom:1.0 FOV:CAMERA_FOV];
		self.panoramaView.camera = camera;
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - GMSPanoramaViewDelegate

- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama
{
//    if (!self.panoramaConfigured || ![[PLTDeviceHandler sharedManager] latestInfo]) {
//        self.panoramaView.camera = [GMSPanoramaCamera cameraWithHeading:0 pitch:0 zoom:1.0];
//        self.panoramaConfigured = YES;
//    }
	
	if (!self.panoramaConfigured || ![CONNECTED_DEVICE cachedInfoForService:PLTServiceOrientation error:nil]) {
		self.panoramaView.camera = [GMSPanoramaCamera cameraWithHeading:0 pitch:0 zoom:1.0];
		self.panoramaConfigured = YES;
	}
}

- (void)panoramaView:(GMSPanoramaView *)view error:(NSError *)erro onMoveNearCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"panoramaView:error: %@ onMoveNearCoordinate:", erro);
}

- (BOOL)panoramaView:(GMSPanoramaView *)panoramaView didTapMarker:(GMSMarker *)marker
{
    return YES;
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
//    if (!HEADSET_CONNECTED) {
//        if ([message hasType:@"event"]) {
//			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
//                NSDictionary *info = [[PLTDeviceHandler sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
//				if (info) {
//					[self headsetInfoDidUpdate:info];
//				}
//            }
//        }
//    }
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.title = @"Street View";
    self.tabBarItem.title = @"Street View";
    self.tabBarItem.image = [UIImage imageNamed:@"buildings_icon.png"];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
        NSLog(@"kReachabilityChangedNotification");
        if ([self checkReachability]) {
            [self locationButton:self];
        }
    }];
    [self.reachability startNotifier];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.panoramaView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:[LocationMonitor sharedMonitor].location.coordinate];
    self.panoramaView.backgroundColor = [UIColor grayColor];
    self.panoramaView.delegate = self;
    self.panoramaView.orientationGestures = NO;
    self.panoramaView.zoomGestures = NO;
    self.view = self.panoramaView;
    
    self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_ios7.png"];//[UIImage imageNamed:@"plt_logo_nav.png"];
	if (!IOS7) pltImage = [UIImage imageNamed:@"pltlabs_nav.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeCenter;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																   style:UIBarButtonItemStyleBordered
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = settingItem;
    
    UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"locationIcon.png"]
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(locationButton:)];
	self.navigationItem.leftBarButtonItem = locationItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.reachabilityImageView.alpha = 0.0;
	
	[self subscribeToServices];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationOverrideDidSelectNewLocationNotification:) name:LocationOverrideDidSelectNewLocation object:nil];
    [[PLTContextServer sharedContextServer] addDelegate:self];
    
    //[TestFlight passCheckpoint:@"STREETVIEW_TAB"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.reachabilityImageView) {
        self.reachabilityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.reachabilityImageView.contentMode = UIViewContentModeCenter;
        self.reachabilityImageView.image = [UIImage imageNamed:(IPAD ? @"no_internet_ipad.png" : @"no_internet_iphone.png")];
        self.reachabilityImageView.alpha = 0.0;
        [self.view addSubview:self.reachabilityImageView];
    }
    
    if ([self checkReachability]) {
        [self locationButton:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
	[self unsubscribeFromServices];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTHeadsetInfoDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LocationOverrideDidSelectNewLocation object:nil];
    [[PLTContextServer sharedContextServer] removeDelegate:self];
}

@end
