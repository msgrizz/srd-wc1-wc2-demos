//
//  HeadViewController.m
//  PLTSensor
//
//  Created by Morgan Davis on 12/29/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import "HeadViewController.h"
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import "PLTDeviceHelper.h"
#import <SceneKit/SceneKit.h>

#define SCENE_KIT

#ifndef SCENE_KIT
#import "ScarlettView.h"
#endif

@interface HeadViewController () <PLTDeviceSubscriber>

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)deviceDidCloseConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;

#ifdef SCENE_KIT
@property(nonatomic,strong) NSArray *rotateNodes;
#endif

@end


@implementation HeadViewController

#pragma mark - Private

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self subscribeToServices];
}

- (void)deviceDidCloseConnectionNotification:(NSNotification *)note
{
	for (SCNNode *n in self.rotateNodes) {
		n.orientation = SCNVector4Make(0, 0, 0, 1);
	}
}

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (CONNECTED_DEVICE) {
		NSError *err = nil;
		//[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModePeriodic andPeriod:MIN_PERIODIC_SUBSCRIPTION_PERIOD error:&err];
		[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModePeriodic andPeriod:MIN_PERIODIC_SUBSCRIPTION_PERIOD error:&err];
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
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	 
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTQuaternion quaternion = ((PLTOrientationTrackingInfo *)theInfo).quaternion;
		
//		PLTQuaternion absQuaternion = {fabs(quaternion.x),fabs(quaternion.y),fabs(quaternion.z),fabs(quaternion.w)};
//		if (absQuaternion.x<.00001 || absQuaternion.y<.00001 || absQuaternion.z<.00001 || absQuaternion.w<.00001) {
//			NSLog(@"*** BAD QUATERNION! ***");
//			return;
//		}
		
#ifdef SCENE_KIT
		int mirror = ([DEFAULTS boolForKey:PLTDefaultsKeyHeadMirrorImage] ? 1 : -1);
		for (SCNNode *n in self.rotateNodes) {
			n.orientation = SCNVector4Make(quaternion.x, quaternion.z * mirror, quaternion.y * mirror, -quaternion.w); // pitch, heading, roll
		}
#else
		// original
		//PLTQuaternion q = {-quaternion.x, quaternion.y, -quaternion.z, quaternion.w}; // Vec4 quaternion = {-q.x, q.y, -q.z, q.w};
		//PLTQuaternion q = {1, 2, 3, 4};
		
		// for "ScarlettView"
		//PLTQuaternion q = {4, 1, 2, 3}; // NO IDEA WHY ORDER MUST BE CHANGED
		PLTQuaternion q = {quaternion.w, -quaternion.x, quaternion.y, -quaternion.z}; // Vec4 quaternion = {-q.x, q.y, -q.z, q.w};
		ScarlettView *view = (ScarlettView *)self.view;
		[view updateRotation:q];
#endif
		
//		if ([DEFAULTS boolForKey:PLTDefaultsKeyGestureRecognition]) {
//			PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
//			[self gestureCheck:(long long)(1000*[[NSDate date] timeIntervalSince1970]) noplane:eulerAngles.y yesplane:eulerAngles.z];
//		}
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nil];
	
	self.title = @"Head";
	self.tabBarItem.title = @"Head";
	self.tabBarItem.image = [UIImage imageNamed:@"head_tab_icon.png"];
	
	// setup navigation item
	
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_banner.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:pltFrame];
	imageView.contentMode = UIViewContentModeCenter;
	imageView.image = pltImage;
	self.navigationItem.titleView = imageView;
	
	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_nav_icon.png"]
																   style:UIBarButtonItemStylePlain
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = actionItem;
	
#ifdef SCENE_KIT
	SCNScene *scene = [SCNScene sceneNamed:@"scarlett"];
	
	SCNNode *cameraNode = [SCNNode node];
	SCNCamera *camera = [SCNCamera camera];
	camera.automaticallyAdjustsZRange = YES;
	camera.xFov = 30;
	camera.yFov = 30;
	cameraNode.camera = camera;
	cameraNode.position = SCNVector3Make(0, -.48, 2.35); // horizontal, vertical (neg down), depth (neg farther)
	[scene.rootNode addChildNode:cameraNode];
	
//	SCNNode *lightNode = [SCNNode node];
//	lightNode.light = [SCNLight light];
//	lightNode.light.type = SCNLightTypeDirectional;
//	lightNode.position = SCNVector3Make(0, 0, 20);
//	[scene.rootNode addChildNode:lightNode];
	
	SCNView *view = [[SCNView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.view = view;
	view.scene = scene;
	view.antialiasingMode = SCNAntialiasingModeMultisampling4X;
	view.allowsCameraControl = NO;
	view.autoenablesDefaultLighting = NO;
	view.backgroundColor = [UIColor colorWithRed:64.0/256.0 green:66.0/256.0 blue:74.0/256.0 alpha:1.0];//[UIColor whiteColor];
	
//	for (SCNNode *n in scene.rootNode.childNodes) {
//		NSLog(@"node: %@", n.name);
//	}
	
	SCNNode *skin = [scene.rootNode childNodeWithName:@"skin" recursively:YES];
	SCNNode *hair = [scene.rootNode childNodeWithName:@"hair" recursively:YES];
	[hair.geometry.materials[0] setDoubleSided:YES];
	SCNNode *reye = [scene.rootNode childNodeWithName:@"reye" recursively:YES];
	SCNNode *leye = [scene.rootNode childNodeWithName:@"leye" recursively:YES];
	
	self.rotateNodes = @[skin, hair, reye, leye];
	
	SCNMatrix4 translation = SCNMatrix4MakeTranslation(0, .5, -.25); // horizontal, vertical (neg up), depth (neg closer)
	for (SCNNode *n in self.rotateNodes) {
		n.pivot = translation;
		//n.geometry.subdivisionLevel = 1;
	}
#else
	ScarlettView *view = [[ScarlettView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.view = view;
#endif
		
	return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self subscribeToServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidCloseConnectionNotification:) name:PLTDeviceDidCloseConnectionNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self unsubscribeFromServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc removeObserver:self name:PLTDeviceDidCloseConnectionNotification object:nil];
}

@end
