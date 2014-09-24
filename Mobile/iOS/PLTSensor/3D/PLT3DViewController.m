//
//  PLT3DViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 11/5/12.
//  Copyright (c) 2012 Cambridge Silicon Radio. All rights reserved.
//

#import "PLT3DViewController.h"
#import "GLGravityView.h"
#import "UIDevice+ScreenSize.h"
#import "PLTDeviceHandler.h"
#import "CC3Foundation.h"
#import "iToast.h"
#import "PLTContextServer.h"
#import "NSData+Base64.h"
#import "StatusWatcher.h"
#import "AppDelegate.h"
//#import "TestFlight.h"
#import "PLTDevice.h"


typedef enum {
    GEST_START,
    GEST_ARM,
    GEST_UP,
    GEST_LEFT,
    GEST_YES,
    GEST_NO
} gesture_states;


@interface PLT3DViewController () <PLTDeviceSubscriber, PLTContextServerDelegate>

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;

- (void)gestureCheck:(long long)thetime noplane:(double) theta yesplane:(double)psi;

@property(nonatomic,strong) IBOutlet GLGravityView      *threeDeeView;
@property(nonatomic,assign) double                      theta_ave;
@property(nonatomic,assign) double                      psi_ave;
@property(nonatomic,assign) long long                   oldtime;
@property(nonatomic,assign) gesture_states              gesture_state;

@end


@implementation PLT3DViewController

#pragma mark - Private

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
		
		[d subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
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

//- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
//{
//    //if (![HeadsetManager sharedManager].isConnected || !DEVICE_REGISTERED) {
//        Vec4 quaternion;
//        NSData *quaternionData = [note userInfo][PLTHeadsetInfoKeyQuaternionData];
//        [quaternionData getBytes:&quaternion length:[quaternionData length]];
//        [self.threeDeeView updateRotation:quaternion];
//	
//	if ([DEFAULTS boolForKey:PLTDefaultsKeyGestureRecognition]) {
//		Vec3 rotationVector;
//        NSData *rotationVectorData = [note userInfo][PLTHeadsetInfoKeyRotationVectorData];
//        [rotationVectorData getBytes:&rotationVector length:[rotationVectorData length]];
//		[self gestureCheck:(long long)(1000*[[NSDate date] timeIntervalSince1970]) noplane:rotationVector.y yesplane:rotationVector.z];
//	}
//    //}
//}

- (void)gestureCheck:(long long)thetime noplane:(double) theta yesplane:(double)psi
{
	if (self.tabBarController.selectedViewController == self) { // face is selected
        self.theta_ave = self.theta_ave * .8 + theta * .2;
        self.psi_ave = self.psi_ave * .8 + psi * .2;
        
        if ((thetime - self.oldtime) > 5000 || (thetime - self.oldtime) < 0)
            self.oldtime = thetime;
        
        if ((thetime - self.oldtime) > 2000 && (self.gesture_state == GEST_UP || self.gesture_state == GEST_LEFT))
        {
            self.gesture_state = GEST_START;
            self.oldtime = thetime;
            
        }
        else if ((thetime - self.oldtime) > 2000 && (self.gesture_state == GEST_YES || self.gesture_state == GEST_NO))
        {
            self.gesture_state = GEST_START;
            self.oldtime = thetime;
            
        }
        else if (((theta - self.theta_ave) < -8) && (self.gesture_state == GEST_START))
        {
            self.gesture_state = GEST_UP;
            self.oldtime = thetime;
        }
        else if ((theta - self.theta_ave) > 8 && ((thetime - self.oldtime) < 1000) && (self.gesture_state == GEST_UP))
        {
            self.gesture_state = GEST_YES;
            self.oldtime = thetime;
            [[iToast makeText:NSLocalizedString(@"\"Yes\" Detected", @"")] show];
            
            
        }
        else if (((psi - self.psi_ave) < -8) && (self.gesture_state == GEST_START))
        {
            self.gesture_state = GEST_LEFT;
            self.oldtime = thetime;
        }
        else if ((psi - self.psi_ave) > 8 && ((thetime - self.oldtime) < 1000) && (self.gesture_state == GEST_LEFT))
        {
            self.gesture_state = GEST_NO;
            self.oldtime = thetime;
            [[iToast makeText:NSLocalizedString(@"\"No\" Detected", @"")] show];
        }
    }
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTQuaternion q = ((PLTOrientationTrackingInfo *)theInfo).quaternion;
		
		//Vec4 quaternion = { -nCalQuat[1], nCalQuat[2], -nCalQuat[3], nCalQuat[0] };
		//Vec4 quaternion = {-q.w, q.x, -q.y, q.z};
		Vec4 quaternion = {-q.x, q.y, -q.z, q.w};
		[self.threeDeeView updateRotation:quaternion];
		
		if ([DEFAULTS boolForKey:PLTDefaultsKeyGestureRecognition]) {
			PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
			[self gestureCheck:(long long)(1000*[[NSDate date] timeIntervalSince1970]) noplane:eulerAngles.y yesplane:eulerAngles.z];
		}
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
//	if (!HEADSET_CONNECTED) {
//        if ([message hasType:@"event"]) {
//			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
//				NSDictionary *info = [[PLTDeviceHandler sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
//				if (info) {
//					NSData *quaternionData = info[PLTHeadsetInfoKeyQuaternionData];
//					Vec4 quaternion;
//					[quaternionData getBytes:&quaternion length:[quaternionData length]];
//					[self.threeDeeView updateRotation:quaternion];
//				}
//            }
//        }
//    }
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        if (IPHONE5) self = [super initWithNibName:@"PL3DViewController_iPhone5" bundle:nibBundleOrNil];
		else self = [super initWithNibName:@"PL3DViewController_iPhone4" bundle:nibBundleOrNil];
    else
        self = [super initWithNibName:@"PL3DViewController_iPad" bundle:nibBundleOrNil];

    self.tabBarItem.title = @"Head";
    self.tabBarItem.image = [UIImage imageNamed:@"head_icon.png"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// setup navigation item
	
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
	
	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																   style:UIBarButtonItemStyleBordered
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = actionItem;
//	}
//	else {
//		self.navigationController.navigationBarHidden = YES;
//		
//		UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav.png"];//[UIImage imageNamed:@"plt_logo_nav.png"];
//		CGRect navFrame = self.navBar.frame;
//		CGRect viewFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
//									  (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
//									  pltImage.size.width + 2,
//									  pltImage.size.height + 2);
//		
//		UIImageView *view = [[UIImageView alloc] initWithFrame:viewFrame];
//		view.contentMode = UIViewContentModeCenter;
//		view.image = pltImage;
//		[self.navBar addSubview:view];
//		
//		UIImage *barImage = [UIImage imageNamed:@"cogBarButton.png"];
//		UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:barImage
//																	   style:UIBarButtonItemStyleBordered
//																	  target:[UIApplication sharedApplication].delegate
//																	  action:@selector(settingsButton:)];
//		((UINavigationItem *)self.navBar.items[0]).rightBarButtonItem = actionItem;
//	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#warning navBar
	[[StatusWatcher sharedWatcher] setActiveNavigationBar:self.navigationController.navigationBar animated:NO];
    [[PLTContextServer sharedContextServer] addDelegate:self];
	
	[self subscribeToServices];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];

    //[TestFlight passCheckpoint:@"SKARLET_TAB"];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[PLTContextServer sharedContextServer] removeDelegate:self];
	
	[self unsubscribeFromServices];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
}

@end
