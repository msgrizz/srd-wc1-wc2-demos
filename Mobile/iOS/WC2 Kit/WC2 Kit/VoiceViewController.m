//
//  VoiceViewController.m
//  WC2 Kit
//
//  Created by Morgan Davis on 2/24/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "VoiceViewController.h"
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import "PLTDeviceHelper.h"
#import "BRDevice.h"
#import "PLTDevice_Internal.h"
#import "BRSubscribeToServicesCommand.h"
#import "BRSubscribedServiceDataEvent.h"
#import <SceneKit/SceneKit.h>


#define SENSOR_DEVICE CONNECTED_DEVICE.brDevice.remoteDevices[@(5)]

#define VOICE_COMMAND_DISTANCE			1
#define VOICE_COMMAND_WHAT_TIME_IS_IT	2
#define VOICE_COMMAND_PAIR_MODE			3
#define VOICE_COMMAND_TALK_TO_CORTANA	4
#define VOICE_COMMAND_LAUNCH_IT			5
#define VOICE_COMMAND_REDIAL			6
#define VOICE_COMMAND_VOICE_MEMO		7
#define VOICE_COMMAND_SECURE			8
#define VOICE_COMMAND_TALK_TO_SIRI		9
#define VOICE_COMMAND_STEP_COUNT		10
#define VOICE_COMMAND_UNLOCK			11
#define VOICE_COMMAND_TALK_TO_GOOGLE	12
#define VOICE_COMMAND_HELP_ME			13
#define VOICE_COMMAND_CALL				14
#define VOICE_COMMAND_RETURN_CALL		15


NSString *DescriptionFromVoiceCommand(int commandID) {
	switch (commandID) {
		case VOICE_COMMAND_DISTANCE: return @"Distance";
		case VOICE_COMMAND_WHAT_TIME_IS_IT: return @"What time is it?";
		case VOICE_COMMAND_PAIR_MODE: return @"Pair mode";
		case VOICE_COMMAND_TALK_TO_CORTANA: return @"Talk to Cortana";
		case VOICE_COMMAND_LAUNCH_IT: return @"Launch it";
		case VOICE_COMMAND_REDIAL: return @"Redial";
		case VOICE_COMMAND_VOICE_MEMO: return @"Voice memo";
		case VOICE_COMMAND_SECURE: return @"Secure";
		case VOICE_COMMAND_TALK_TO_SIRI: return @"Talk to Siri";
		case VOICE_COMMAND_STEP_COUNT: return @"Step count";
		case VOICE_COMMAND_UNLOCK: return @"Unlock";
		case VOICE_COMMAND_TALK_TO_GOOGLE: return @"Talk to Google";
		case VOICE_COMMAND_HELP_ME: return @"Help me";
		case VOICE_COMMAND_CALL: return @"Call";
		case VOICE_COMMAND_RETURN_CALL: return @"Return call";
	}
	return @"";
}


@interface VoiceViewController () <PLTDeviceSubscriber, PLTDeviceBRDevicePassthroughDelegate>

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)deviceDidCloseConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;
- (SCNMaterial *)textMaterial;
- (void)displayText:(NSString *)string;

@property(nonatomic, retain) SCNNode	*offScreenTextNode;
@property(nonatomic, retain) SCNNode	*textNode;

@end


@implementation VoiceViewController

#pragma mark - Private

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self subscribeToServices];
}

- (void)deviceDidCloseConnectionNotification:(NSNotification *)note
{
	
}

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (CONNECTED_DEVICE) {
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:0x0016 // voice commands
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																							period:0];
		[SENSOR_DEVICE sendMessage:message];
		
		CONNECTED_DEVICE.passthroughDelegate = self; // listen for voice events
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

- (SCNMaterial *)textMaterial
{
	static SCNMaterial *material = nil;
	if (!material) {
		material = [SCNMaterial material];
		material.specular.contents = [UIColor colorWithWhite:0.6 alpha:1];
		//material.reflective.contents = [UIImage imageNamed:@"color_envmap"];
		//material.reflective.contents = [UIImage imageNamed:@"color_envmap_highsaturation"];
		material.reflective.contents = [UIImage imageNamed:@"color_envmap_evenhighersaturation"];
		material.shininess = 0.2;
	}
	return material;
}

- (void)displayText:(NSString *)string
{
	SCNScene *scene = (SCNScene *)((SCNView *)(self.view)).scene;
	
	CGFloat textSize = 5.0;
	CGFloat extrusionDepth = 1.75;
	CGFloat flatness = .005;
	CGFloat chamferRadius = .1;
	if (string.length > 8) {
		textSize = 4.0;
		extrusionDepth = 1.5;
		flatness = .005;
		chamferRadius = .09;
		if (string.length > 12) {
			textSize = 3.1;
			extrusionDepth = 1.25;
			flatness = .009;
			chamferRadius = .05;
		}
	}
	SCNText *text = [SCNText textWithString:string extrusionDepth:extrusionDepth];
	text.alignmentMode = kCAAlignmentCenter;
	text.flatness = flatness;
	text.chamferRadius = chamferRadius;
	text.font = [UIFont fontWithName:@"Avenir-heavy" size:textSize];
	text.materials = @[[self textMaterial]];
	SCNNode *newTextNode = [SCNNode nodeWithGeometry:text];
	SCNVector3 max;
	[newTextNode getBoundingBoxMin:nil max:&max];
	//CGFloat startScale = .6;
	newTextNode.position = SCNVector3Make(-max.x/2.0, -20, 0);
	newTextNode.rotation = SCNVector4Make(1, 0, 0, M_PI/6.0);
	//newTextNode.scale = SCNVector3Make(startScale, startScale, startScale);
	[scene.rootNode addChildNode:newTextNode];
	
	CGFloat animationScale = 1.10;
	
//	if (self.offScreenTextNode) {
//		[self.offScreenTextNode removeFromParentNode];
//	}
	
	// animate old node out
	if (self.textNode) {
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:.35 * animationScale];
		[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
		SCNVector3 oldMax;
		[self.textNode getBoundingBoxMin:nil max:&oldMax];
		self.textNode.position = SCNVector3Make(-oldMax.x/2.0, 20, 0);
		self.textNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/4.0);
		//self.textNode.scale = SCNVector3Make(.6, .6, .6);
		[SCNTransaction commit];
		//self.offScreenTextNode = self.textNode;
	}
	
	// animate new node in
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:.75 * animationScale];
	[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	newTextNode.position = SCNVector3Make(-max.x/2.0, -max.y/2.0, 0);
	newTextNode.rotation = SCNVector4Make(1, 0, 0, 0);
	//newTextNode.scale = SCNVector3Make(1, 1, 1);
	[SCNTransaction commit];
	
//	CABasicAnimation *inAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//	inAnimation.duration = 2;
//	//inAnimation.repeatCount = 1;
//	inAnimation.toValue = [NSValue valueWithSCNVector3:toPosition];
//	inAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//	[self.inTextNode addAnimation:inAnimation forKey:@"position"];
	
	self.textNode = newTextNode;
}

- (void)settingsButton:(id)sender
{
	static int dick = 1;
	NSString *str = DescriptionFromVoiceCommand(dick);
	[self displayText:str];
	dick++;
	if (dick > VOICE_COMMAND_RETURN_CALL) dick = 1;
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - PLTDeviceBRDevicePassthroughDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
	//NSLog(@"BRDeviceDidConnect: %@", device);
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
	//NSLog(@"BRDeviceDidDisconnect: %@", device);
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
	//NSLog(@"BRDevice: %@ didFailConnectWithError: %d", device, ioBTError);
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
	NSLog(@"BRDevice: %@ didReceiveEvent: %@", device, event);
	
	if ([event isKindOfClass:[BRSubscribedServiceDataEvent class]]) {
		BRSubscribedServiceDataEvent *sde = (BRSubscribedServiceDataEvent *)event;
		if (sde.serviceID == 0x0016) { // voice command
			uint8_t command;
			[sde.serviceData getBytes:&command length:sizeof(uint8_t)];
			NSLog(@"Voice command with ID: %02X", command);
			[self displayText:DescriptionFromVoiceCommand(command)];
		}
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResult:(BRSettingResult *)result
{
	//NSLog(@"BRDevice: %@ didReceiveSettingResult: %@", device, result);
}

- (void)BRDevice:(BRDevice *)device didRaiseSettingException:(BRException *)exception
{
	//NSLog(@"BRDevice: %@ didRaiseSettingException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didRaiseCommandException:(BRException *)exception
{
	//NSLog(@"BRDevice: %@ didRaiseCommandException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice
{
	//NSLog(@"BRDevice: %@ didFindRemoteDevice: %@", device, remoteDevice);
}

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
	//NSString *hexString = PLTHexStringFromData(data, 2);
	//NSLog(@"--> %@", hexString);
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	//NSString *hexString = PLTHexStringFromData(data, 2);
	//NSLog(@"<-- %@", hexString);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nil];
	
	self.title = @"Voice";
	self.tabBarItem.title = @"Voice";
	self.tabBarItem.image = [UIImage imageNamed:@"voice_tab_icon.png"];
	
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
	
//	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_nav_icon.png"]
//																   style:UIBarButtonItemStylePlain
//																  target:[UIApplication sharedApplication].delegate
//																  action:@selector(settingsButton:)];
	
	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_nav_icon.png"]
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(settingsButton:)];
	
	self.navigationItem.rightBarButtonItem = actionItem;
	

	// scene kit
	
	SCNScene *scene = [SCNScene scene];
	
	SCNCamera *camera = [SCNCamera camera];
	camera.automaticallyAdjustsZRange = YES;
	camera.xFov = 30;
	camera.yFov = 30;
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = camera;
	cameraNode.position = SCNVector3Make(0, 0, 50); // horizontal, vertical (neg down), depth (neg farther)
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
	view.allowsCameraControl = YES;
	view.autoenablesDefaultLighting = NO;
	//view.backgroundColor = [UIColor grayColor];
	view.backgroundColor = [UIColor colorWithRed:64.0/256.0 green:66.0/256.0 blue:74.0/256.0 alpha:1.0]; // top of PLT site dark gray/blue
	//view.backgroundColor = [UIColor colorWithRed:95.0/256.0 green:106.0/256.0 blue:114.0/256.0 alpha:1.0]; // bottom of PLT site light gray/blue
	
	SCNNode *originNode = [SCNNode node];
	originNode.position = SCNVector3Zero;
	
//	NSString *string = @"What.";
//	CGFloat textSize = 5.0;
//	CGFloat extrusionDepth = 1.75;
//	CGFloat flatness = .005;
//	CGFloat chamferRadius = .1;
//	if (string.length > 8) {
//		textSize = 4.0;
//		extrusionDepth = 1.5;
//		flatness = .005;
//		chamferRadius = .09;
//		if (string.length > 12) {
//			textSize = 3.1;
//			extrusionDepth = 1.25;
//			flatness = .009;
//			chamferRadius = .05;
//		}
//	}
//	SCNText *text = [SCNText textWithString:string extrusionDepth:extrusionDepth];
//	text.alignmentMode = kCAAlignmentCenter;
//	text.flatness = flatness;
//	text.chamferRadius = chamferRadius;
//	text.font = [UIFont fontWithName:@"Avenir-heavy" size:textSize];
//	text.materials = @[[self textMaterial]];
//	SCNNode *textNode = [SCNNode nodeWithGeometry:text];
//	SCNVector3 max;
//	[textNode getBoundingBoxMin:nil max:&max];
//	SCNVector3 position = SCNVector3Zero;
//	position = SCNVector3Make(-max.x/2.0, -max.y/2.0, 0);
//	textNode.position = position;
//	[scene.rootNode addChildNode:textNode];
	
	
	
	
//	SCNTransformConstraint *constraint = [SCNTransformConstraint transformConstraintInWorldSpace:YES withBlock:^SCNMatrix4(SCNNode *node, SCNMatrix4 transform) {
//		SCNV
//		CGFloat dZ = sinf(<#float#>);
//		SCNMatrix4MakeTranslation(1, 1, dZ)
//	}];
	
	
	

	SCNLight *ambientLight = [SCNLight light];
	SCNNode *ambientLightNode = [SCNNode node];
	ambientLight.type = SCNLightTypeAmbient;
	ambientLight.color = [UIColor colorWithWhite:.05 alpha:1.0];
	ambientLightNode.light = ambientLight;
	[scene.rootNode addChildNode:ambientLightNode];

	SCNLight *diffuseLight = [SCNLight light];
	SCNNode *diffuseLightNode = [SCNNode node];
	diffuseLight.type = SCNLightTypeDirectional;
	diffuseLight.color = [UIColor colorWithWhite:.5 alpha:1.0];
	diffuseLightNode.light = diffuseLight;
	diffuseLightNode.position = SCNVector3Make(-10, 50, 50);
	diffuseLightNode.constraints = @[[SCNLookAtConstraint lookAtConstraintWithTarget:originNode]];
	[scene.rootNode addChildNode:diffuseLightNode];
	
	SCNLight *diffuseLight2 = [SCNLight light];
	SCNNode *diffuseLightNode2 = [SCNNode node];
	diffuseLight2.type = SCNLightTypeDirectional;
	diffuseLight2.color = [UIColor colorWithWhite:.2 alpha:1.0];
	diffuseLightNode2.light = diffuseLight;
	diffuseLightNode2.position = SCNVector3Make(10, -50, 50);
	diffuseLightNode2.constraints = @[[SCNLookAtConstraint lookAtConstraintWithTarget:originNode]];
	[scene.rootNode addChildNode:diffuseLightNode2];
	
	return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self subscribeToServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidCloseConnectionNotification:) name:PLTDeviceDidCloseConnectionNotification object:nil];
	
	CONNECTED_DEVICE.passthroughDelegate = self; // listen for voice events
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
