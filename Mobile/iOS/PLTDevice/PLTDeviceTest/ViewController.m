//
//  ViewController.m
//  PLTDeviceTest
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"


@interface ViewController () <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

- (void)newDeviceAvailableNotification:(NSNotification *)notification;

@property(nonatomic, strong)	PLTDevice		*device;

@end


@implementation ViewController

#pragma mark - Private

- (IBAction)calButton:(id)sender
{
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
}

- (IBAction)queryButton:(id)sender
{
	[self.device queryInfo:self forService:PLTServiceOrientationTracking];
}

- (IBAction)subscribeButton:(id)sender
{
	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
//	err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
//	if (err) NSLog(@"Error: %@", err);
	
//	err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModePeriodic minPeriod:200];
//	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange minPeriod:500];
	if (err) NSLog(@"Error: %@", err);

	err = [self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	// note: this doesn't work right.
	err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
}

- (IBAction)unsubscribeButton:(id)sender
{
	//[self.device unsubscribeFromAll:self];
	[self.device unsubscribe:self fromService:PLTServiceOrientationTracking];
	[self.device unsubscribe:self fromService:PLTServiceTaps];
}

- (IBAction)resetButton:(id)sender
{
	[self.device setCalibration:nil forService:PLTServicePedometer];
}

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
}

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
//		self.headingLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.x)];
//		self.pitchLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.y)];
//		self.rollLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.z)];
		
		self.orientationLabel.text = [NSString stringWithFormat:@"{ %.1f, %.1f, %.1f }", eulerAngles.x, eulerAngles.y, eulerAngles.z];
	}
	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
		if ([(PLTFreeFallInfo *)theInfo isInFreeFall]) {
			[self.device setCalibration:nil forService:PLTServiceFreeFall];
		}
	}
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:@"ViewController_iPhone" bundle:nil];
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(newDeviceAvailableNotification:)
												 name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

@end
