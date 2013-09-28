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
#import "MainWindowController.h"


#define HT_FILTER_CONSTANT		.8
#define CAM_SWTICH_TIME			.5 // seconds
#define FORCE_DON				NO


float DistanceBetweenPoints(CGPoint p1, CGPoint p2)
{
	return sqrt(pow(p2.x-p1.x,2) + pow(p2.y-p1.y,2));
}


@interface HTDemoController () <PLTContextServerDelegate>

- (void)log:(NSString *)text, ...;
- (void)updateCamLocations;
- (void)processHSInfo:(NSDictionary *)info;
- (HTCam)closestCamForOrientation:(Vec3)orientation;
- (void)startCamSwitchTimerForCam:(HTCam)cam;
- (void)stopCamSwitchTimer;
- (void)camSwitchTimer:(NSTimer *)theTimer;

@property (nonatomic, retain) NSDictionary *_latestHeadsetInfo;
@property (nonatomic, assign) CGPoint cam1Location;
@property (nonatomic, assign) CGPoint cam2Location;
@property (nonatomic, assign) CGPoint cam3Location;
@property (nonatomic, assign) float htFilterConstant;
@property (nonatomic, assign) Vec3 htOrientation;
@property (nonatomic, assign) Vec3 filteredHTOrientation;
@property (nonatomic, retain) NSTimer *camSwitchTimer;
@property (nonatomic, assign) HTCam camToSwitchTo;

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
	DLog(@"Starting demo.");
	
	if (!self.isStarted) {
		self.isStarted = YES;
	}
	
	[self.delegate HTDemoControllerDidStart:self];
}

- (void)stopDemo
{
	DLog(@"Stopping demo.");
	
	if (self.isStarted) {
		self.isStarted = NO;
	}
	
	[self.delegate HTDemoControllerDidStop:self];
	
	[[VideoSwitchController sharedController] activateCam:HTCamNone];
	//[[VideoSwitchController sharedController] activateCam:HTCamAux];
}

#pragma mark - Private

- (void)log:(NSString *)text, ...
{
	va_list list;
	va_start(list, text);
    NSString *message = [[NSString alloc] initWithFormat:text arguments:list];
	va_end(list);
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTHTCamNotificationLogMessage object:nil userInfo:@{PLTHTCamNotificationKeyLogMessage: message}];
}

- (void)updateCamLocations
{
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam1Location]), &_cam1Location);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam2Location]), &_cam2Location);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam3Location]), &_cam3Location);
}

- (void)processHSInfo:(NSDictionary *)info
{
	Vec3 orientation;
	NSData *orientationData = info[PLTHeadsetInfoKeyRotationVectorData];
	[orientationData getBytes:&orientation length:[orientationData length]];
	self.htOrientation = orientation;
	BOOL isDonned = [info[PLTHeadsetInfoKeyIsDonned] boolValue];
	
	if (FORCE_DON && !isDonned) {
		[self stopDemo];
	}
	else {
		if (self.isStarted) {
			self.htFilterConstant = HT_FILTER_CONSTANT;
//			// low-pass the HT orientation
			Vec3 filteredOrientation;
			filteredOrientation.x = orientation.x * self.htFilterConstant + self.filteredHTOrientation.x * (1.0 - self.htFilterConstant);
			filteredOrientation.y = orientation.y * self.htFilterConstant + self.filteredHTOrientation.y * (1.0 - self.htFilterConstant);
			filteredOrientation.z = orientation.z * self.htFilterConstant + self.filteredHTOrientation.z * (1.0 - self.htFilterConstant);
			self.filteredHTOrientation = filteredOrientation;
			
			HTCam cam = [self closestCamForOrientation:self.filteredHTOrientation];
			[self startCamSwitchTimerForCam:cam];
		}
	}
}

- (HTCam)closestCamForOrientation:(Vec3)orientation
{
//	DLog(@"closestCamForOrientation: (%.2f, %.2f)", orientation.x, orientation.y);
//	
//	DLog(@"self.cam1Location: %@", NSStringFromPoint(self.cam1Location));
//	DLog(@"self.cam2Location: %@", NSStringFromPoint(self.cam2Location));
//	DLog(@"self.cam3Location: %@", NSStringFromPoint(self.cam3Location));
	
	float o = orientation.x;
	float a = self.cam1Location.x; if ((a-o) > 180) a = self.cam1Location.x-360;
	float b = self.cam2Location.x; if ((b-o) > 180) b = self.cam2Location.x-360;
	float c = self.cam3Location.x; if ((c-o) > 180) c = self.cam3Location.x-360;
	
	int cam1Distance = abs((int)lroundf(a-o));
	int cam2Distance = abs((int)lroundf(b-o));
	int cam3Distance = abs((int)lroundf(c-o));
	
//	DLog(@"cam1Distance: %d", cam1Distance);
//	DLog(@"cam2Distance: %d", cam2Distance);
//	DLog(@"cam3Distance: %d", cam3Distance);
	
	if ((cam1Distance<=cam2Distance) && (cam1Distance<=cam3Distance)) { // cam1
		return HTCam1;
	}
	else if ((cam3Distance<=cam1Distance) && (cam3Distance<=cam2Distance)) { // cam2
		return HTCam3;
	}
	return HTCam2;
	
//	DLog(@"self.cam1Location: %@", NSStringFromPoint(self.cam1Location));
//	DLog(@"self.cam2Location: %@", NSStringFromPoint(self.cam2Location));
//	DLog(@"self.cam3Location: %@", NSStringFromPoint(self.cam3Location));
//	
//	float cam1Distance = DistanceBetweenPoints(self.cam1Location, CGPointMake(orientation.x, orientation.y));
//	float cam1Distance_r = DistanceBetweenPoints(self.cam1Location, CGPointMake(orientation.x+360, orientation.y+360));
//	float cam2Distance = DistanceBetweenPoints(self.cam2Location, CGPointMake(orientation.x, orientation.y));
//	float cam2Distance_r = DistanceBetweenPoints(self.cam2Location, CGPointMake(orientation.x+360, orientation.y+360));
//	float cam3Distance = DistanceBetweenPoints(self.cam3Location, CGPointMake(orientation.x, orientation.y));
//	float cam3Distance_r = DistanceBetweenPoints(self.cam3Location, CGPointMake(orientation.x+360, orientation.y+360));
//	
//	DLog(@"cam1Distance: %.2f", cam1Distance);
//	DLog(@"cam1Distance_r: %.2f", cam1Distance_r);
//	DLog(@"cam2Distance: %.2f", cam2Distance);
//	DLog(@"cam2Distance_r: %.2f", cam2Distance_r);
//	DLog(@"cam3Distance: %.2f", cam3Distance);
//	DLog(@"cam3Distance_r: %.2f", cam3Distance_r);
//	
//	if ((cam1Distance<=cam2Distance) && (cam1Distance<=cam3Distance)) { // cam1
//		return HTCam1;
//	}
//	else if ((cam3Distance<=cam1Distance) && (cam3Distance<=cam2Distance)) { // cam2
//		return HTCam3;
//	}
//	return HTCam2;
}

- (void)startCamSwitchTimerForCam:(HTCam)cam
{
	DLog(@"startCamSwitchTimerForCam: %d", cam);
	
	if (cam != self.camToSwitchTo) {
		[self stopCamSwitchTimer];
	}
	
	self.camToSwitchTo = cam;
	self.camSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:CAM_SWTICH_TIME target:self selector:@selector(camSwitchTimer:) userInfo:nil repeats:NO];
}

- (void)stopCamSwitchTimer
{
	DLog(@"stopCamSwitchTimer");
	
	if ([self.camSwitchTimer isValid]) {
		[self.camSwitchTimer invalidate];
		self.camSwitchTimer = nil;
	}
}

- (void)camSwitchTimer:(NSTimer *)theTimer
{
	DLog(@"switchTimer:");
	
	[self.delegate HTDemoController:self changedActiveCam:self.camToSwitchTo];
	[[VideoSwitchController sharedController] activateCam:self.camToSwitchTo];
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
