//
//  HTDemoController.m
//  HTCam
//
//  Created by Davis, Morgan on 7/17/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "HTDemoController.h"
#import "PLTContextServer.h"
#import "PLTHeadsetManager.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import "SettingsWindowController.h"
#import "VideoSwitchController.h"


float DistanceBetweenPoints(CGPoint p1, CGPoint p2)
{
	return sqrt(pow(p2.x-p1.x,2) + pow(p2.y-p1.y,2));
}


@interface HTDemoController () <PLTContextServerDelegate>

- (void)updateCamLocations;
- (void)processHSInfo:(NSDictionary *)info;
- (HTCam)closestCamForOrientation:(Vec3)orientation;

@property (nonatomic, retain) NSDictionary *_latestHeadsetInfo;
@property (nonatomic, assign) CGPoint cam1Location;
@property (nonatomic, assign) CGPoint cam2Location;
@property (nonatomic, assign) CGPoint cam3Location;
@property (nonatomic, assign) float htFilterConstant;
@property (nonatomic, assign) Vec3 htOrientation;
@property (nonatomic, assign) Vec3 filteredHTOrientation;

@end


@implementation HTDemoController

@synthesize cam1Location = _cam1Location;
@synthesize cam2Location = _cam2Location;
@synthesize cam3Location = _cam3Location;

@dynamic latestHeadsetInfo;

- (NSDictionary *)latestHeadsetInfo
{
	return self._latestHeadsetInfo;
}

#pragma mark - Public

+ (HTDemoController *)sharedController
{
	static HTDemoController *controller = nil;
	if (!controller) controller = [[HTDemoController alloc] init];
	return controller;
}

- (void)startDemo
{
	NSLog(@"Starting demo.");
	
	if (!self.isStarted) {
		self.isStarted = YES;
	}
	
	[self.delegate HTDemoControllerDidStart:self];
}

- (void)stopDemo
{
	NSLog(@"Stopping demo.");
	
	if (self.isStarted) {
		self.isStarted = NO;
	}
	
	[self.delegate HTDemoControllerDidStop:self];
	
	[[VideoSwitchController sharedController] activateCam:HTCamNone];
	//[[VideoSwitchController sharedController] activateCam:HTCamAux];
}

#pragma mark - Private

- (void)updateCamLocations
{
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam1Location]), &_cam1Location);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam2Location]), &_cam2Location);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam3Location]), &_cam3Location);
	// cheating and including filter constant here, too
	self.htFilterConstant = [[DEFAULTS objectForKey:PLTDefaultsKeyHeadTrackingDataFilter] floatValue];
}

- (void)processHSInfo:(NSDictionary *)info
{
	Vec3 orientation;
	NSData *orientationData = info[PLTHeadsetInfoKeyRotationVectorData];
	[orientationData getBytes:&orientation length:[orientationData length]];
	self.htOrientation = orientation;
	BOOL isDonned = [info[PLTHeadsetInfoKeyIsDonned] boolValue];
	
	if (!isDonned) {
		[self stopDemo];
	}
	else {
		if (self.isStarted) {
			self.htFilterConstant = .2;
//			// low-pass the HT orientation
			Vec3 filteredOrientation;
			filteredOrientation.x = orientation.x * self.htFilterConstant + self.filteredHTOrientation.x * (1.0 - self.htFilterConstant);
			filteredOrientation.y = orientation.y * self.htFilterConstant + self.filteredHTOrientation.y * (1.0 - self.htFilterConstant);
			filteredOrientation.z = orientation.z * self.htFilterConstant + self.filteredHTOrientation.z * (1.0 - self.htFilterConstant);
			self.filteredHTOrientation = filteredOrientation;
			
			HTCam activeCam = [self closestCamForOrientation:self.filteredHTOrientation];
			[self.delegate HTDemoController:self changedActiveCam:activeCam];
			
			[[VideoSwitchController sharedController] activateCam:activeCam];
		}
	}
}

- (HTCam)closestCamForOrientation:(Vec3)orientation
{
//	NSLog(@"closestCamForOrientation: (%.2f, %.2f)", orientation.x, orientation.y);
//	
//	NSLog(@"self.cam1Location: %@", NSStringFromPoint(self.cam1Location));
//	NSLog(@"self.cam2Location: %@", NSStringFromPoint(self.cam2Location));
//	NSLog(@"self.cam3Location: %@", NSStringFromPoint(self.cam3Location));
	
	float o = orientation.x;
	float a = self.cam1Location.x; if ((a-o) > 180) a = self.cam1Location.x-360;
	float b = self.cam2Location.x; if ((b-o) > 180) b = self.cam2Location.x-360;
	float c = self.cam3Location.x; if ((c-o) > 180) c = self.cam3Location.x-360;
	
	int cam1Distance = abs((int)lroundf(a-o));
	int cam2Distance = abs((int)lroundf(b-o));
	int cam3Distance = abs((int)lroundf(c-o));
	
//	NSLog(@"cam1Distance: %d", cam1Distance);
//	NSLog(@"cam2Distance: %d", cam2Distance);
//	NSLog(@"cam3Distance: %d", cam3Distance);
	
	if ((cam1Distance<=cam2Distance) && (cam1Distance<=cam3Distance)) { // cam1
		return HTCam1;
	}
	else if ((cam3Distance<=cam1Distance) && (cam3Distance<=cam2Distance)) { // cam2
		return HTCam3;
	}
	return HTCam2;
	
//	NSLog(@"self.cam1Location: %@", NSStringFromPoint(self.cam1Location));
//	NSLog(@"self.cam2Location: %@", NSStringFromPoint(self.cam2Location));
//	NSLog(@"self.cam3Location: %@", NSStringFromPoint(self.cam3Location));
//	
//	float cam1Distance = DistanceBetweenPoints(self.cam1Location, CGPointMake(orientation.x, orientation.y));
//	float cam1Distance_r = DistanceBetweenPoints(self.cam1Location, CGPointMake(orientation.x+360, orientation.y+360));
//	float cam2Distance = DistanceBetweenPoints(self.cam2Location, CGPointMake(orientation.x, orientation.y));
//	float cam2Distance_r = DistanceBetweenPoints(self.cam2Location, CGPointMake(orientation.x+360, orientation.y+360));
//	float cam3Distance = DistanceBetweenPoints(self.cam3Location, CGPointMake(orientation.x, orientation.y));
//	float cam3Distance_r = DistanceBetweenPoints(self.cam3Location, CGPointMake(orientation.x+360, orientation.y+360));
//	
//	NSLog(@"cam1Distance: %.2f", cam1Distance);
//	NSLog(@"cam1Distance_r: %.2f", cam1Distance_r);
//	NSLog(@"cam2Distance: %.2f", cam2Distance);
//	NSLog(@"cam2Distance_r: %.2f", cam2Distance_r);
//	NSLog(@"cam3Distance: %.2f", cam3Distance);
//	NSLog(@"cam3Distance_r: %.2f", cam3Distance_r);
//	
//	if ((cam1Distance<=cam2Distance) && (cam1Distance<=cam3Distance)) { // cam1
//		return HTCam1;
//	}
//	else if ((cam3Distance<=cam1Distance) && (cam3Distance<=cam2Distance)) { // cam2
//		return HTCam3;
//	}
//	return HTCam2;
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
	if ([message hasType:@"event"]) {
		if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
			NSDictionary *info = [[PLTHeadsetManager sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
			if (info) {
				self._latestHeadsetInfo = info;
				[self processHSInfo:info];
			}
		}
	}
}

#pragma mark - NSObject

- (id)init
{
	self = [super init];
	
	[[PLTContextServer sharedContextServer] addDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserverForName:PLTHTCamNotificationCamLocationChanged object:nil queue:NULL usingBlock:^(NSNotification *note) {
		[self updateCamLocations];
	}];
	
	[self updateCamLocations];
	
	return self;
}

@end
