//
//  HeadViewController.m
//  CSR Wireless Sensor
//
//  Created by Morgan Davis on 12/29/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import "HeadViewController.h"
#import "PLTDevice.h"
#import "PLTDeviceHandler.h"
#import <SceneKit/SceneKit.h>


@interface HeadViewController () <PLTDeviceSubscriber>

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;

@property(nonatomic,strong) SCNView	*sceneView;

@end


@implementation HeadViewController

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
		[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
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


#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTQuaternion quaternion = ((PLTOrientationTrackingInfo *)theInfo).quaternion;
		SCNNode *scarlett = self.sceneView.scene.rootNode;
		scarlett.orientation = SCNVector4Make(quaternion.x, quaternion.z, quaternion.y , -quaternion.w);
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	self.title = @"Head";
	self.tabBarItem.title = @"Head";
	self.tabBarItem.image = [UIImage imageNamed:@"head_icon.png"];
	
	// setup navigation item
	
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_ios7.png"];
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
																   style:UIBarButtonItemStylePlain
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = actionItem;
	
	// setup scarlett
	
	self.sceneView = [[SCNView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.sceneView.scene = [SCNScene sceneNamed:@"scarlett"];
	self.sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
	//self.sceneView.backgroundColor = [UIColor blackColor];
	self.sceneView.allowsCameraControl = YES;
	self.view = self.sceneView;
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self subscribeToServices];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[self unsubscribeFromServices];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
}

@end
