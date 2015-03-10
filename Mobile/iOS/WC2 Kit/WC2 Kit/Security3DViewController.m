//
//  Security3DViewController.m
//  WC2 Kit
//
//  Created by Morgan Davis on 3/4/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "Security3DViewController.h"
#import <SceneKit/SceneKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SecuritySceneView.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import "PLTDevice_Internal.h"
#import "PLTDeviceHelper.h"
#import "Reachability.h"
#import "SettingsViewController.h"
#import "BRDevice.h"
#import "BRSubscribeToServicesCommand.h"
#import "BRSubscribedServiceDataEvent.h"
#import "SecurityHelper.h"


//#define FAKE_SIGN

#define RELOCK_DELAY	10.0 // s
#define SENSOR_DEVICE	CONNECTED_DEVICE.brDevice.remoteDevices[@(5)]


typedef enum {
	StateStart,
	StateFirstFactor,
	StateSecondFactor,
	StateAwaitingUnlock,
	StateUnlocked,
//	StateDoorOpen
} DemoState;

typedef enum {
	DirectionalLightModeLow,
	DirectionalLightModeMedium,
	DirectionalLightModeHigh
} DirectionalLightMode;

typedef enum {
	SpotlightPositionOffScene,
	SpotlightPositionScene,
	SpotlightPositionFirstFactor,
	SpotlightPositionSecondFactor,
	SpotlightPositionDoorFactor,
} SpotlightPosition;

typedef enum {
	FactorTextModeNormal,
	FactorTextModePass,
	FactorTextModeFail
} FactorTextMode;

typedef enum {
	PLTLockStateLocked,
	PLTLockStateUnlocked
} PLTLockState;


@interface Security3DViewController () <SecuritySceneViewEventDelegate, PLTDeviceSubscriber, PLTDeviceBRDevicePassthroughDelegate, SecurityHelperSignDelegate, NSURLConnectionDelegate> {
	SystemSoundID	jiggleSoundID;
	SystemSoundID	unlockSoundID;
	SystemSoundID	lockSoundID;
	SystemSoundID	openSoundID;
	SystemSoundID	closeSoundID;
}

- (void)setupScene;
- (void)loadSounds;
- (void)setupAudioRouting;
- (void)playJiggleDoorSound;
- (void)playUnlockSound;
- (void)playLockSound;
- (void)playDoorOpenSound;
- (void)playDoorClosedSound;
- (void)setDirectionalLightMode:(DirectionalLightMode)mode animated:(BOOL)animated;
- (void)moveSpotlightToPosition:(SpotlightPosition)direction animated:(BOOL)aniamted;
- (void)jiggleDoor;
- (void)unlockDoor;
- (void)lockDoor:(BOOL)playSound;
- (void)openDoor;
- (void)closeDoor:(BOOL)playSound;
- (void)shakeNo:(SCNNode *)aNode;
- (NSString *)activeLockitronLockID;
- (SCNMaterial *)textMaterial:(FactorTextMode)mode;
- (void)doTouchID;
- (void)doDeviceSign;
- (void)didGetUnlockVoiceCommand;
- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;
- (BOOL)checkReachability;
- (void)deviceChanged:(NSNotification *)aNotification;
- (void)checkListenForVoiceCommands;
- (void)setLockState:(PLTLockState)state lockID:(NSString *)lockID;
- (void)startLockTimer;
- (void)stopLockTimer;
- (void)lockTimer:(NSTimer *)aTimer;
- (void)resetState;

@property(nonatomic, retain) SCNNode	*doorNode;
@property(nonatomic, retain) SCNNode	*doorHandleNode;
@property(nonatomic, retain) SCNNode	*touchIDNode;
@property(nonatomic, retain) SCNNode	*firstFactorNode;
@property(nonatomic, retain) SCNNode	*secondFactorNode;
@property(nonatomic, retain) SCNNode	*wc2Node;
@property(nonatomic, retain) SCNNode	*fidoNode;
@property(nonatomic, retain) SCNNode	*wc2FIDONode;
@property(nonatomic, retain) SCNNode	*firstFactorTextNode;
@property(nonatomic, retain) SCNNode	*secondFactorTextNode;
@property(nonatomic, retain) SCNNode	*signStatusTextNode;
@property(nonatomic, retain) SCNNode	*directionalLightNode;
@property(nonatomic, retain) SCNNode	*spotLightNode;
@property(nonatomic, assign) DemoState	state;
@property(nonatomic, assign) BOOL		door3DOpen;
@property(nonatomic,strong)	Reachability						*reachability;
@property(nonatomic,strong)	UIImageView							*reachabilityImageView;
@property(nonatomic,strong) NSURLConnection						*lockConnection;
@property(nonatomic,strong) NSTimer								*lockTimer;

@end


@implementation Security3DViewController

#pragma mark - Private

- (void)setupScene
{
	SecuritySceneView *scnView = (SecuritySceneView *)self.view;
	
	scnView.eventDelegate = self;
	
	SCNScene *scene = [SCNScene sceneNamed:@"door"];
	scnView.scene = scene;
	
	scnView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
	scnView.allowsCameraControl = NO;
	scnView.autoenablesDefaultLighting = NO;
	scnView.backgroundColor = [UIColor colorWithRed:64.0/256.0 green:66.0/256.0 blue:74.0/256.0 alpha:1.0];
	
	SCNNode *rootNode = scene.rootNode;
	
	SCNNode *cameraNode = [rootNode childNodeWithName:@"camera" recursively:NO];
	cameraNode.position = SCNVector3Make(cameraNode.position.x, cameraNode.position.y + .1, cameraNode.position.z);
	
	SCNNode *groundNode = [scene.rootNode childNodeWithName:@"ground" recursively:NO];
	[groundNode removeFromParentNode];
	
	SCNFloor *floor = [SCNFloor floor];
	floor.reflectivity = .25;
	SCNNode *floorNode = [SCNNode nodeWithGeometry:floor];
	floorNode.position = SCNVector3Make(floorNode.position.x, -.9, floorNode.position.z);
	[scene.rootNode addChildNode:floorNode];
	
	[[scene.rootNode childNodeWithName:@"lights" recursively:NO] removeFromParentNode];
	
	// lightMetal
	SCNMaterial *lightMetalMaterial = [SCNMaterial material];
	UIColor *lightGrayBlue = [UIColor colorWithRed:156.0/256.0 green:158.0/256.0 blue:162.0/256.0 alpha:1.0];
	UIColor *darkerGrayBlue = [UIColor colorWithRed:145.0/256.0 green:148.0/256.0 blue:151.0/256.0 alpha:1.0];
	lightMetalMaterial.diffuse.contents = darkerGrayBlue;
	lightMetalMaterial.specular.contents = darkerGrayBlue;
	lightMetalMaterial.shininess = .2;
//	lightMetalMaterial.diffuse.contents = [UIColor colorWithWhite:.8 alpha:1.0];
//	lightMetalMaterial.specular.contents = [UIColor colorWithWhite:.5 alpha:1.0];
	
	// dark metal
	SCNMaterial *darkMetalMaterial = [SCNMaterial material];
	darkMetalMaterial.diffuse.contents = [UIColor colorWithRed:64.0/256.0 green:66.0/256.0 blue:74.0/256.0 alpha:1.0];
	darkMetalMaterial.specular.contents = [UIColor colorWithRed:64.0/256.0 green:66.0/256.0 blue:74.0/256.0 alpha:1.0];
	darkMetalMaterial.shininess = .8;
//	darkMetalMaterial.diffuse.contents = [UIColor colorWithWhite:.65 alpha:1.0];
//	darkMetalMaterial.specular.contents = [UIColor colorWithWhite:.4 alpha:1.0];
	
	// change the door and handle pivot points. this apparently causes a translation, too...
	self.doorNode = [rootNode childNodeWithName:@"door" recursively:NO];
	self.doorNode.pivot = SCNMatrix4MakeTranslation(.44, 0, 0);
	self.doorNode.position = SCNVector3Make(self.doorNode.position.x + .44, self.doorNode.position.y, self.doorNode.position.z);
	self.doorHandleNode = [self.doorNode childNodeWithName:@"handle" recursively:NO];
	self.doorHandleNode.pivot = SCNMatrix4MakeTranslation(0, .18, 0); // this appears to be in its own strange coordinate space... (y???)
	self.doorHandleNode.position = SCNVector3Make(self.doorHandleNode.position.x - .041, self.doorHandleNode.position.y, self.doorHandleNode.position.z);
	
	[self.doorNode childNodeWithName:@"panel" recursively:NO].geometry.firstMaterial = lightMetalMaterial;
	[self.doorNode childNodeWithName:@"handle" recursively:NO].geometry.firstMaterial = lightMetalMaterial;
	[self.doorNode childNodeWithName:@"handle_shaft" recursively:NO].geometry.firstMaterial = lightMetalMaterial;
	[self.doorNode childNodeWithName:@"handle_backing" recursively:NO].geometry.firstMaterial = lightMetalMaterial;
	
	SCNNode *frameNode = [rootNode childNodeWithName:@"frame" recursively:NO];
	
	[frameNode childNodeWithName:@"thenge" recursively:NO].geometry.firstMaterial = lightMetalMaterial;
	[frameNode childNodeWithName:@"bhenge" recursively:NO].geometry.firstMaterial = lightMetalMaterial;
	[frameNode childNodeWithName:@"tframe" recursively:NO].geometry.firstMaterial = darkMetalMaterial;
	[frameNode childNodeWithName:@"lframe" recursively:NO].geometry.firstMaterial = darkMetalMaterial;
	[frameNode childNodeWithName:@"rframe" recursively:NO].geometry.firstMaterial = darkMetalMaterial;
	
	self.directionalLightNode = [SCNNode node];
	self.directionalLightNode.light = [SCNLight light];
	self.directionalLightNode.light.type = SCNLightTypeDirectional;
	//self.directionalLightNode.castsShadow = YES;
	self.directionalLightNode.position = SCNVector3Make(0, 2, 5);
	self.directionalLightNode.rotation = SCNVector4Make(1, 0, 0, -atan(self.directionalLightNode.position.y/self.directionalLightNode.position.z) + .45);
	[self setDirectionalLightMode:DirectionalLightModeLow animated:NO];
	[scene.rootNode addChildNode:self.directionalLightNode];
	
	// spot light
	self.spotLightNode = [SCNNode node];
	self.spotLightNode.light = [SCNLight light];
	self.spotLightNode.light.type = SCNLightTypeSpot;
	self.spotLightNode.light.castsShadow = YES;
	//	self.spotLightNode.light.shadowRadius = 4;
	//	self.spotLightNode.light.zNear = 0;
	//	self.spotLightNode.light.zFar = 1000.0;
	//self.spotLightNode.light.shadowBias = 100;
	self.spotLightNode.light.shadowSampleCount = 2;
	//self.spotLightNode.light.shadowRadius = 10;
	self.spotLightNode.light.shadowMapSize = CGSizeMake(1024*4, 1024*4);
	self.spotLightNode.light.color = [UIColor colorWithWhite:1.0 alpha:1.0];
	self.spotLightNode.position = SCNVector3Make(0, 5, 3);
	[scene.rootNode addChildNode:self.spotLightNode];
	
	self.firstFactorNode = [SCNNode node];
	self.secondFactorNode = [SCNNode node];
	
	CGFloat overlayZDistance = .05;
	
	self.touchIDNode = [SCNNode node];
	self.touchIDNode.name = @"touchID";
	self.touchIDNode.geometry = [SCNPlane planeWithWidth:.75 height:.75];
	self.touchIDNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"touchid_diffuse"];
	//self.touchIDNode.geometry.firstMaterial.emission.contents = [UIImage imageNamed:@"touchid_emissive"];
	self.touchIDNode.position = SCNVector3Make(-0.9, 2, overlayZDistance);
	[self.firstFactorNode addChildNode:self.touchIDNode];
	
	self.wc2FIDONode = [SCNNode node];
	
	self.wc2Node = [SCNNode node];
	self.wc2Node.name = @"wc2";
	self.wc2Node.geometry = [SCNPlane planeWithWidth:1.20 height:1.20];
	self.wc2Node.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"wc2_diffuse"];
	self.wc2Node.position = SCNVector3Make(.9, 2, overlayZDistance);
	[self.secondFactorNode addChildNode:self.wc2Node];
	
	self.fidoNode = [SCNNode node];
	self.fidoNode.name = @"fido";
	self.fidoNode.geometry = [SCNPlane planeWithWidth:.35 height:.35];
	self.fidoNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"fido_diffuse"];
	self.fidoNode.position = SCNVector3Make(1.0, 2.15, overlayZDistance);
	[self.wc2FIDONode addChildNode:self.fidoNode];
	
	[self.secondFactorNode addChildNode:self.wc2FIDONode];
	
	SCNText *firstFactorText = [SCNText textWithString:@"First Factor" extrusionDepth:.15];
	firstFactorText.alignmentMode = kCAAlignmentLeft;
	firstFactorText.flatness = .00001;
	//firstFactorText.chamferRadius = .1;
	firstFactorText.font = [UIFont fontWithName:@"Avenir-heavy" size:.44];
	firstFactorText.firstMaterial = [self textMaterial:NO];
	self.firstFactorTextNode = [SCNNode nodeWithGeometry:firstFactorText];
	self.firstFactorTextNode.name = @"ff";
	self.firstFactorTextNode.position = SCNVector3Make(-1.5, 2.55, overlayZDistance);
	self.firstFactorTextNode.scale = SCNVector3Make(.5, .5, .5);
	[self.firstFactorNode addChildNode:self.firstFactorTextNode];
	
	SCNText *secondFactorText = [SCNText textWithString:@"Second Factor" extrusionDepth:.15];
	secondFactorText.alignmentMode = kCAAlignmentRight;
	secondFactorText.flatness = .00001;
	//firstFactorText.chamferRadius = .1;
	secondFactorText.font = [UIFont fontWithName:@"Avenir-heavy" size:.50];
	secondFactorText.firstMaterial = [self textMaterial:NO];
	self.secondFactorTextNode = [SCNNode nodeWithGeometry:secondFactorText];
	self.secondFactorTextNode.name = @"sf";
	self.secondFactorTextNode.position = SCNVector3Make(.02, 2.55, overlayZDistance);
	self.secondFactorTextNode.scale = SCNVector3Make(.5, .5, .5);
	[self.secondFactorNode addChildNode:self.secondFactorTextNode];
	
	SCNText *signStatusText = [SCNText textWithString:@"Retrieving challenge from server..." extrusionDepth:.125];
	signStatusText.alignmentMode = kCAAlignmentCenter;
	signStatusText.flatness = .00001;
	//firstFactorText.chamferRadius = .1;
	signStatusText.font = [UIFont fontWithName:@"Avenir-heavy" size:.4];
	signStatusText.firstMaterial = [[self textMaterial:NO] copy];
	signStatusText.firstMaterial.diffuse.contents = [UIColor darkGrayColor];
	self.signStatusTextNode = [SCNNode nodeWithGeometry:signStatusText];
	//self.signStatusTextNode.position = SCNVector3Make(.04, 1.5, overlayZDistance);
	self.signStatusTextNode.position = SCNVector3Make(.03, 2.45, overlayZDistance - .02);
	self.signStatusTextNode.scale = SCNVector3Make(.20, .20, .20);
	//[self.secondFactorNode addChildNode:self.signStatusTextNode];
	
	
	[rootNode addChildNode:self.firstFactorNode];
	[rootNode addChildNode:self.secondFactorNode];
	
	
	
	//	SCNPlane *monsterPlane = [SCNPlane planeWithWidth:.25 height:.25];
	//	SCNNode *monsterNode = [SCNNode nodeWithGeometry:monsterPlane];
	////	monsterNode.geometry.firstMaterial.ambient.contents = nil;
	////	monsterNode.geometry.firstMaterial.specular.contents = nil;
	//	monsterNode.geometry.firstMaterial.emission.contents = [UIImage imageNamed:@"monster_eyes_emissive"];
	//	//monsterNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"monster_emissive"];
	////	monsterNode.geometry.firstMaterial.transparent.contents = [UIImage imageNamed:@"monster_emissive"];
	//	monsterNode.geometry.firstMaterial.multiply.contents = [UIColor colorWithWhite:.2 alpha:1.0];
	//	monsterNode.position = SCNVector3Make(0, -.5, -3);
	//	[rootNode addChildNode:monsterNode];
}

- (void)loadSounds
{
	NSString *str = [[NSBundle mainBundle] pathForResource:@"door_open" ofType:@"m4a"];
	NSURL *strURL = [NSURL fileURLWithPath:str];
	OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)strURL, &openSoundID);
	if (error) NSLog(@"AudioServicesCreateSystemSoundID error: %ld",error);
	
	str = [[NSBundle mainBundle] pathForResource:@"door_close" ofType:@"mp3"];
	strURL = [NSURL fileURLWithPath:str];
	error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)strURL, &closeSoundID);
	if (error) NSLog(@"AudioServicesCreateSystemSoundID error: %ld",error);
	
	str = [[NSBundle mainBundle] pathForResource:@"door_jiggle" ofType:@"m4a"];
	strURL = [NSURL fileURLWithPath:str];
	error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)strURL, &jiggleSoundID);
	if (error) NSLog(@"AudioServicesCreateSystemSoundID error: %ld",error);
	
	str = [[NSBundle mainBundle] pathForResource:@"door_unlock" ofType:@"m4a"];
	strURL = [NSURL fileURLWithPath:str];
	error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)strURL, &unlockSoundID);
	if (error) NSLog(@"AudioServicesCreateSystemSoundID error: %ld",error);
	
	str = [[NSBundle mainBundle] pathForResource:@"door_lock" ofType:@"m4a"];
	strURL = [NSURL fileURLWithPath:str];
	error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)strURL, &lockSoundID);
	if (error) NSLog(@"AudioServicesCreateSystemSoundID error: %ld",error);
}

- (void)setupAudioRouting
{
//	AudioSessionInterruptionListener inInterruptionListener = NULL;
//	OSStatus error;
//	if ((error = AudioSessionInitialize(NULL, NULL, inInterruptionListener, NULL))) {
//		NSLog(@"*** Error initializing audio session: %lu ***", error);
//	}
	
//	SInt32  ambient = kAudioSessionCategory_AmbientSound;
//	if ((error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof (ambient), &ambient))) {
//		NSLog(@"*** Error setting audio session to ambient: %lu ***", error);
//	}
//	
//	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//	if ((error = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride))) {
//		NSLog(@"*** Error setting audio session override: %lu ***", error);
//	}
	
//	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);    
//	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//	AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride);
}

- (void)jiggleDoor
{
	[self playJiggleDoorSound];
	
	CGFloat animationTime = .18;
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:animationTime];
	[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	
//	self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, 0); // DOWN
//	self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2); // UP
	self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, 1.0/.8); // middle
	
	[SCNTransaction setCompletionBlock:^{
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:animationTime];
		[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
		
		[SCNTransaction setCompletionBlock:^{
			[SCNTransaction begin];
			[SCNTransaction setAnimationDuration:animationTime];
			[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
			self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, 1.0/.8);

			[SCNTransaction setCompletionBlock:^{
				[SCNTransaction begin];
				[SCNTransaction setAnimationDuration:animationTime];
				[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
				self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
				
				[SCNTransaction commit];
			}];
			
			[SCNTransaction commit];
		}];
		
		[SCNTransaction commit];
	}];

	[SCNTransaction commit];
}

- (void)unlockDoor
{
	[self playUnlockSound];
	
	CGFloat animationTime = .5;
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:animationTime];
	[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	
	//self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, 0); // DOWN
	//self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2); // UP
	self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, 1.0/.95); // open
	
	[SCNTransaction setCompletionBlock:^{
		
	}];
	
	[SCNTransaction commit];
}

- (void)lockDoor:(BOOL)playSound
{
	CGFloat animationTime = .5;
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:animationTime];
	[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	
	//self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, 0); // DOWN
	self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2); // UP
	//self.doorHandleNode.rotation = SCNVector4Make(0, 0, 1, 1.0/.8); // middle
	
	[SCNTransaction setCompletionBlock:^{
		if (playSound) {
			[self playLockSound];
		}
	}];
	
	[SCNTransaction commit];
}

- (void)openDoor
{
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:2.0];
	[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

	self.doorNode.rotation = SCNVector4Make(0, 1, 0, M_PI / 1.5);
	
	[SCNTransaction commit];
	
	[self playDoorOpenSound];
	
	self.door3DOpen = YES;
}

- (void)closeDoor:(BOOL)playSound
{
	float animationTime = 2.0;
	
	[self lockDoor:NO];
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:animationTime];
	[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	
	self.doorNode.rotation = SCNVector4Make(0, 1, 0, 0);
	
//	[SCNTransaction setCompletionBlock:^{
//		[self lockDoor:NO];
//	}];
	
	[SCNTransaction commit];
	
	if (playSound) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((animationTime - .5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self playDoorClosedSound];
		});
	}
	
	self.door3DOpen = NO;
}

- (void)shakeNo:(SCNNode *)aNode
{
	CGFloat animationTime = .05;
	CGFloat distance = .05;
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:animationTime/2.0];
	[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

	SCNVector3 pos = aNode.position;
	
	aNode.position = SCNVector3Make(pos.x -distance, pos.y, pos.z);
	
	[SCNTransaction setCompletionBlock:^{
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:animationTime];
		[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		aNode.position = SCNVector3Make(pos.x + distance, pos.y, pos.z);
		
		[SCNTransaction setCompletionBlock:^{
			[SCNTransaction begin];
			[SCNTransaction setAnimationDuration:animationTime];
			[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			aNode.position = SCNVector3Make(pos.x - distance, pos.y, pos.z);
			
			[SCNTransaction setCompletionBlock:^{
				[SCNTransaction begin];
				[SCNTransaction setAnimationDuration:animationTime];
				[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
				aNode.position = SCNVector3Make(pos.x + distance, pos.y, pos.z);
				
				[SCNTransaction setCompletionBlock:^{
					[SCNTransaction begin];
					[SCNTransaction setAnimationDuration:animationTime/2.0];
					[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
					aNode.position = SCNVector3Make(pos.x, pos.y, pos.z);
					
					[SCNTransaction commit];
				}];
				
				[SCNTransaction commit];
			}];
			
			[SCNTransaction commit];
		}];
		
		[SCNTransaction commit];
	}];
	
	[SCNTransaction commit];
}

- (void)playJiggleDoorSound
{
	AudioServicesPlaySystemSound(jiggleSoundID);
}

- (void)playUnlockSound
{
	AudioServicesPlaySystemSound(unlockSoundID);
}

- (void)playLockSound
{
	AudioServicesPlaySystemSound(lockSoundID);
}

- (void)playDoorOpenSound
{
	AudioServicesPlaySystemSound(openSoundID);
}

- (void)playDoorClosedSound
{
	AudioServicesPlaySystemSound(closeSoundID);
}

- (void)setDirectionalLightMode:(DirectionalLightMode)mode animated:(BOOL)animated
{
	//UIColor *color = (on ? [UIColor colorWithWhite:.95 alpha:1.0] : [UIColor colorWithWhite:0 alpha:1.0]);
	
	UIColor *color = nil;
	switch (mode) {
		case DirectionalLightModeLow:
			color = [UIColor colorWithWhite:.2 alpha:1.0];
			break;
		case DirectionalLightModeMedium:
			color = [UIColor colorWithWhite:.3 alpha:1.0];
			break;
		case DirectionalLightModeHigh:
			color = [UIColor colorWithWhite:.9 alpha:1.0];
			break;
		default:
			break;
	}
	
	if (animated) {
		float animationTime = 1.0;
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:animationTime];
		[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	}
	
	self.directionalLightNode.light.color = color;
	
	if (animated) {
		[SCNTransaction commit];
	}
}

- (void)moveSpotlightToPosition:(SpotlightPosition)direction animated:(BOOL)aniamted
{
	BOOL doAnimation = (direction == SpotlightPositionOffScene ? NO : aniamted);
	
	if (doAnimation) {
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:1.0];
		[SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	}
	
	SCNVector3 toAngles;
	CGFloat toInnerAngle;
	CGFloat toOutlerAngle;
	
	switch (direction) {
		case SpotlightPositionOffScene: {
			toAngles = SCNVector3Make(-atan(self.spotLightNode.position.y/self.spotLightNode.position.z) + 1.5, 0, 0);
			toInnerAngle = 50.0;
			toOutlerAngle = 56.0;
			break; }
		case SpotlightPositionScene: {
			toAngles = SCNVector3Make(-atan(self.spotLightNode.position.y/self.spotLightNode.position.z) + .20, 0, 0);
			toInnerAngle = 50.0;
			toOutlerAngle = 56.0;
			break; }
		case SpotlightPositionFirstFactor: {
			CGFloat targetYOffset = self.touchIDNode.position.y + self.firstFactorTextNode.position.y - self.touchIDNode.position.y - 0.1;
			CGFloat targetXOffset = self.touchIDNode.position.x + .01;
			toAngles = SCNVector3Make(-atan((self.spotLightNode.position.y - targetYOffset)/self.spotLightNode.position.z),
															-atan((self.spotLightNode.position.x + targetXOffset)/self.spotLightNode.position.z),
															0);
			toInnerAngle = 18.0;
			toOutlerAngle = 21.0;
			break; }
		case SpotlightPositionSecondFactor: {
//			CGFloat targetYOffset = self.wc2Node.position.y + self.secondFactorTextNode.position.y - self.wc2Node.position.y - 0.00;
//			CGFloat targetXOffset = self.wc2Node.position.x - .01;
			CGFloat targetYOffset = self.wc2Node.position.y + self.secondFactorTextNode.position.y - self.wc2Node.position.y + .08;
			CGFloat targetXOffset = self.wc2Node.position.x - .05;
			toAngles = SCNVector3Make(-atan((self.spotLightNode.position.y - targetYOffset)/self.spotLightNode.position.z),
															-atan((self.spotLightNode.position.x + targetXOffset)/self.spotLightNode.position.z),
															0);
			toInnerAngle = 23.0;
			toOutlerAngle = 26.0;
			break; }
		case SpotlightPositionDoorFactor: {
			toAngles = SCNVector3Make(-atan(self.spotLightNode.position.y/self.spotLightNode.position.z), 0, 0);
			toInnerAngle = 15.0;
			toOutlerAngle = 18.0;
			break; }
	}
	
	self.spotLightNode.eulerAngles = toAngles;
	self.spotLightNode.light.spotInnerAngle = toInnerAngle;
	self.spotLightNode.light.spotOuterAngle = toOutlerAngle;
	
	if (doAnimation) {
		[SCNTransaction commit];
	}
}

- (SCNMaterial *)textMaterial:(FactorTextMode)mode
{
	SCNMaterial *material = [SCNMaterial material];
	
	switch (mode) {
  case FactorTextModeNormal: {
			material.specular.contents = [UIColor colorWithWhite:.5 alpha:1.0];
			material.reflective.contents = [UIImage imageNamed:@"color_envmap_evenhighersaturation"];
			material.shininess = .3;
			break; }
		case FactorTextModePass: {
			UIColor *lightGreen = [UIColor colorWithRed:0.0 green:180.0/255.0 blue:0.0/255.0 alpha:1.0];
			UIColor *darkGreen = [UIColor colorWithRed:0.0 green:100.0/255.0 blue:0.0/255.0 alpha:1.0];
			//material.specular.contents = green;
			material.diffuse.contents = darkGreen;
			material.emission.contents = darkGreen;
			break; }
		case FactorTextModeFail: {
			UIColor *red = [UIColor colorWithRed:.75 green:0.0/200.0 blue:0.0/255.0 alpha:1.0];
			UIColor *darkRed = [UIColor colorWithRed:.75 green:0.0/120.0 blue:0.0/255.0 alpha:1.0];
			//material.specular.contents = green;
			material.diffuse.contents = darkRed;
			material.emission.contents = red;
			break; }
	}
	
	return material;
}

//- (void)setTouchIDEmissive:(BOOL)flag
//{
//	SCNMaterial *material = [SCNMaterial material];
//	
//	material.diffuse.contents = [UIImage imageNamed:@"touchid_diffuse"];
//	
//	if (flag) {
//		material.emission.contents = [UIImage imageNamed:@"touchid_diffuse"];
//	}
//	else {
//		
//	}
//	
//	self.touchIDNode.geometry.firstMaterial = material;
//	
////	id contents;
////	if (flag) contents = [self.touchIDNode.geometry.firstMaterial.diffuse.contents copy];
////	self.touchIDNode.geometry.firstMaterial.emission.contents = contents;
//}

- (void)doTouchID
{
	NSLog(@"doTouchID");
	
	LAContext *lsContext = [[LAContext alloc] init];
	[lsContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
			  localizedReason:@"First Factor Authentication"
						reply:^(BOOL success, NSError *error) {
							int64_t delayInSeconds = .5;
							dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
							dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
								if (success) {
									self.firstFactorTextNode.geometry.firstMaterial = [self textMaterial:FactorTextModePass];
									//[self setTouchIDEmissive:YES];
									[self moveSpotlightToPosition:SpotlightPositionSecondFactor animated:YES];
									self.state = StateSecondFactor;
								}
								else {
									self.firstFactorTextNode.geometry.firstMaterial = [self textMaterial:FactorTextModeFail];
									[self shakeNo:self.firstFactorNode];
								}
							});
						}];
}

- (void)doDeviceSign
{
	NSLog(@"doDeviceSign");
	
	SecurityHelper *sh = [SecurityHelper sharedHelper];
	sh.serverAddress = SECURITY_FIDO_ADDRESS;
	sh.serverUsername = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice][PLTDefaultsKeySecurityFIDOUsername];
	sh.serverPassword = SECURITY_FIDO_PASSWORD;
	[self.secondFactorNode addChildNode:self.signStatusTextNode];
#ifdef FAKE_SIGN
	[self securityHelperDidAuthenticate:self];
#else
	[sh sign:self];
#endif
}

- (void)didGetUnlockVoiceCommand
{
	NSLog(@"didGetUnlockVoiceCommand");
	
	if (self.state == StateAwaitingUnlock) {
		[self setLockState:PLTLockStateUnlocked lockID:[self activeLockitronLockID]];
		[self unlockDoor];
		[self startLockTimer];
		
		self.state = StateUnlocked;
	}
	else {
		NSLog(@"Not authenticated.");
	}
}

- (void)didGetLockVoiceCommand
{
	NSLog(@"didGetLockVoiceCommand");
	
	if (self.state == StateUnlocked) {
		if (self.door3DOpen) {
			[self closeDoor:YES];
		}
		else {
			[self lockDoor:YES];
		}
		//[self moveSpotlightToPosition:SpotlightPositionScene animated:YES];
		[self resetState];
	}
}

- (NSString *)activeLockitronLockID
{
	NSDictionary *device = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice];
	NSString *lockID = device[PLTDefaultsKeySecurityDeviceID];
	return lockID;
}

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	NSLog(@"deviceDidOpenConnectionNotification");
	
	[self resetState];
	[self subscribeToServices];
}

- (void)deviceDidCloseConnectionNotification:(NSNotification *)note
{
	NSLog(@"deviceDidCloseConnectionNotification:");
	
	[self resetState];
	[self moveSpotlightToPosition:SpotlightPositionOffScene animated:NO];
	[self setDirectionalLightMode:DirectionalLightModeLow animated:NO];
}

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	if (CONNECTED_DEVICE) {
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:0x0016 // voice commands
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																							period:0];
		[SENSOR_DEVICE sendMessage:message];
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (void)unsubscribeFromServices
{
	NSLog(@"unsubscribeFromServices");
	
	if (CONNECTED_DEVICE) {
		//[d unsubscribeFromAll:self];
		
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:0x0016 // voice commands
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																							period:0];
		[SENSOR_DEVICE sendMessage:message];
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (BOOL)checkReachability
{
	NetworkStatus status = [self.reachability currentReachabilityStatus];
	
	if (status==ReachableViaWiFi || status==ReachableViaWWAN) {
		self.reachabilityImageView.alpha = 0.0;
		return YES;
	}
	else {
		self.reachabilityImageView.alpha = 1.0;
	}
	return NO;
}

- (void)deviceChanged:(NSNotification *)aNotification
{
	NSLog(@"deviceChanged:");
	NSLog(@"device: %@", [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice]);
}

- (void)checkListenForVoiceCommands
{
	if (self.state == StateAwaitingUnlock || self.state == StateUnlocked) {
		CONNECTED_DEVICE.passthroughDelegate = self; // listen for voice events
	}
}

- (void)setLockState:(PLTLockState)state lockID:(NSString *)lockID
{
	NSString *accessToken = @"0ed01e72a1374dd306f92e4b042653e37c13bb2f65517963fcc42f6c27636881";
	NSString *urlString = [NSString stringWithFormat:@"https://api.lockitron.com/v2/locks/%@", lockID];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"PUT"];
	NSString *lockUnlock = (state == PLTLockStateLocked ? @"lock" : @"unlock");
	NSString *argString = [NSString stringWithFormat:@"access_token=%@&state=%@", accessToken, lockUnlock];
	NSData *argData = [argString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:argData];
	[request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[argData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	self.lockConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)startLockTimer
{
	NSLog(@"startLockTimer");
	[self stopLockTimer];
	self.lockTimer = [NSTimer scheduledTimerWithTimeInterval:RELOCK_DELAY * 1000 target:self selector:@selector(lockTimer:) userInfo:nil repeats:NO];
}

- (void)stopLockTimer
{
	NSLog(@"stopLockTimer");
	if (self.lockTimer) {
		[self.lockTimer invalidate];
		self.lockTimer = nil;
	}
}

- (void)lockTimer:(NSTimer *)aTimer
{
	NSLog(@"lockTimer:");
	[self resetState];
}

- (void)resetState
{
	self.firstFactorTextNode.geometry.firstMaterial = [self textMaterial:NO];
	self.secondFactorTextNode.geometry.firstMaterial = [self textMaterial:NO];
	[self.signStatusTextNode removeFromParentNode];
	//[self setTouchIDEmissive:NO];
	
	NSDictionary *device = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice];
	NSLog(@"Locking %@...", device[PLTDefaultsKeySecurityDeviceName]);
	NSString *lockID = device[PLTDefaultsKeySecurityDeviceID];
	[self stopLockTimer];
	[self setLockState:PLTLockStateLocked lockID:lockID];
	
	self.state = StateStart;
	
	if (self.door3DOpen) {
		[self closeDoor:NO];
	}
	[self lockDoor:NO];
	[self setDirectionalLightMode:DirectionalLightModeHigh animated:YES];
	[self moveSpotlightToPosition:SpotlightPositionOffScene animated:YES];
}

#pragma mark - SecuritySceneViewEventDelegate

- (void)securitySceneView:(SecuritySceneView *)theView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"securitySceneView:touchesEnded: %@ withEvent: %@", touches, event);
	
	if (CONNECTED_DEVICE.isConnectionOpen) {
		CGPoint location = [touches.anyObject locationInView:self.view];
		NSArray *hits = [((SCNView *)self.view) hitTest:location options:nil];
		NSMutableArray *names = [NSMutableArray array];
		for (SCNHitTestResult *r in hits) {
			SCNNode *n = r.node;
			if (n.name) {
				[names addObject:n.name];
			}
		}
		
		NSLog(@"Hit: %@", names);
		
		// important to do this first since hits to the handle will also hit the panel
		/*if ([names containsObject:@"handle"] || [names containsObject:@"handle_shaft"] || [names containsObject:@"handle_backing"]) {
		 if (self.state == StateUnlocked) {
			[self jiggleDoor];
		 }
		 else {
			[self openDoor];
			[self setLockState:PLTLockStateUnlocked lockID:[self activeLockitronLockID]];
		 }
		 }
		 else */if ([names containsObject:@"panel"]) {
			 
			 if (self.state == StateUnlocked && !self.door3DOpen) {
				 [self openDoor];
			 }
			 else if (self.state == StateUnlocked && self.door3DOpen) {
				 [self closeDoor:YES];
				 [self resetState];
			 }
			 else {
				 [self jiggleDoor];
			 }
		 }
		 else if ([names containsObject:@"ff"] || [names containsObject:@"touchID"]) {
			 
			 if (self.state == StateStart) {
				 [self setDirectionalLightMode:DirectionalLightModeMedium animated:YES];
				 [self moveSpotlightToPosition:SpotlightPositionFirstFactor animated:YES];
				 self.state = StateFirstFactor;
			 }
			 else if (self.state == StateFirstFactor) {
				 [self doTouchID];
			 }
		 }
		 else if ([names containsObject:@"sf"] || [names containsObject:@"wc2"] || [names containsObject:@"fido"]) {
			 
			 if (self.state == StateSecondFactor) {
				 [self doDeviceSign];
			 }
		 }
//		 else {
//			 [self resetState];
//		 }
	}
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
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
			if (command == 0x0B) { // "unlock"
				[self didGetUnlockVoiceCommand];
			}
			else if (command==0x08) { // "secure"
				[self didGetLockVoiceCommand];
			}
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

#pragma mark - SecurityHelperSignDelegate

- (void)securityHelper:(SecurityHelper *)theHelper didUpdateSigningState:(SigningState)state
{
	NSLog(@"securityHelper: %@ didUpdateSigningState: %d", theHelper, state);
	
	SCNText *text = (SCNText *)self.signStatusTextNode.geometry;
	
	switch (state) {
		case SigningStateRetrievingEnrollments:
			text.string = @"Retrieving challenge from server...";
			break;
		case SigningStateSigningOnDevice:
			text.string = @"Signing challenge on Plantronics...";
			break;
		case SigningStateVerifyingSignatureWithServer:
			text.string = @"Verifying signature with server...";
			break;
	}
}

- (void)securityHelperDidAuthenticate:(SecurityHelper *)theHelper
{
	NSLog(@"securityHelperDidAuthenticate: %@", theHelper);

	self.secondFactorTextNode.geometry.firstMaterial = [self textMaterial:FactorTextModePass];
	[self moveSpotlightToPosition:SpotlightPositionDoorFactor animated:YES];
	[self.signStatusTextNode removeFromParentNode];
	self.state = StateAwaitingUnlock;
	
	[self checkListenForVoiceCommands];
}

- (void)securityHelperDidFailAuthenticate:(SecurityHelper *)theHelper
{
	NSLog(@"securityHelperDidFailAuthenticate: %@", theHelper);

	self.secondFactorTextNode.geometry.firstMaterial = [self textMaterial:FactorTextModeFail];
	[self.signStatusTextNode removeFromParentNode];
	[self shakeNo:self.secondFactorNode];
}

- (void)securityHelper:(SecurityHelper *)theHelper didEncounterErrorAuthenticating:(NSError *)error
{
	NSLog(@"securityHelper: %@ didEncounterErrorAuthenticating: %@", theHelper, error);
	
	[CONNECTED_DEVICE closeConnection];
	[self resetState];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection:didReceiveResponse: %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection:didReceiveData: %@", data);
	
	NSError *error;
	id parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error) {
		NSLog(@"Error deserializing JSON data: %@", error);
	}
	else {
		NSLog(@"parsedData: %@", parsedData);
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
{
	NSLog(@"connection:didSendBodyData: %lu", (long)bytesWritten);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading: %@", connection);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nil bundle:nil];

	self.view = [[SecuritySceneView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	self.title = @"U2F";
	self.tabBarItem.title = @"U2F";
	self.tabBarItem.image = [UIImage imageNamed:@"security_tab_icon.png"];
	
	self.view.backgroundColor = [UIColor colorWithRed:64.0/256.0 green:66.0/256.0 blue:74.0/256.0 alpha:1.0];
	
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
	
	self.reachability = [Reachability reachabilityForInternetConnection];
	[[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		NSLog(@"kReachabilityChangedNotification");
		if ([self checkReachability]) {
			//[self connectOpenTok];
		}
	}];
	[self.reachability startNotifier];
	
	[self setupScene];
	[self loadSounds];
	[self setupAudioRouting];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.reachabilityImageView.alpha = 0.0;
	
	[self resetState];
	
	[self moveSpotlightToPosition:SpotlightPositionOffScene animated:NO];
	
	if (CONNECTED_DEVICE.isConnectionOpen) {
		[self setDirectionalLightMode:DirectionalLightModeHigh animated:NO];
	}
	else {
		[self setDirectionalLightMode:DirectionalLightModeLow animated:NO];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.reachabilityImageView) {
		self.reachabilityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		self.reachabilityImageView.contentMode = UIViewContentModeCenter;
		self.reachabilityImageView.image = [UIImage imageNamed:@"no_internet_connection.png"];
		self.reachabilityImageView.alpha = 0.0;
		[self.view addSubview:self.reachabilityImageView];
	}
	
	if ([self checkReachability]) {
		
	}
	
	[self subscribeToServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidCloseConnectionNotification:) name:PLTDeviceDidCloseConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceChanged:) name:PLTSettingsSecurityDeviceChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self resetState];
	[self unsubscribeFromServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc removeObserver:self name:PLTDeviceDidCloseConnectionNotification object:nil];
	[nc removeObserver:self name:PLTSettingsSecurityDeviceChangedNotification object:nil];
}

@end
