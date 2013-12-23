//
//  ViewController.m
//  PLTDeviceTest
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"


@interface ViewController () <PLTDeviceInfoObserver>

- (IBAction)calButton:(id)sender;
- (IBAction)queryButton:(id)sender;
- (IBAction)subscribeButton:(id)sender;
- (IBAction)unsubscribeButton:(id)sender;
- (IBAction)resetButton:(id)sender;
- (void)registerForDeviceNotifications;
- (void)newDeviceAvailableNotification:(NSNotification *)notification;
- (void)didOpenDeviceConnectionNotification:(NSNotification *)notification;
- (void)didFailToOpenDeviceConnectionNotification:(NSNotification *)notification;
- (void)deviceDidDisconnectNotification:(NSNotification *)notification;

@property(nonatomic, strong)	PLTDevice           *device;
@property(nonatomic, strong)	IBOutlet UILabel	*orientationLabel;

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

- (void)registerForDeviceNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newDeviceAvailableNotification:)
                                                 name:PLTNewDeviceAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didOpenDeviceConnectionNotification:)
                                                 name:PLTDidOpenDeviceConnectionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailToOpenDeviceConnectionNotification:)
                                                 name:PLTDidFailToOpenDeviceConnectionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidDisconnectNotification:)
                                                 name:PLTDeviceDidDisconnectNotification object:nil];
}

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNotificationKey];
        //self.device.connectionDelegate;
		[self.device openConnection];
	}
}

- (void)didOpenDeviceConnectionNotification:(NSNotification *)notification
{
    NSLog(@"didOpenDeviceConnectionNotification: %@", notification.userInfo[PLTDeviceNotificationKey]);
}

- (void)didFailToOpenDeviceConnectionNotification:(NSNotification *)notification
{
    NSLog(@"didFailToOpenDeviceConnectionNotification: %@ error: %@", notification.userInfo[PLTDeviceNotificationKey], notification.userInfo[PLTConnectionErrorNotificationKey]);
	self.device = nil;
}

- (void)deviceDidDisconnectNotification:(NSNotification *)notification
{
    NSLog(@"deviceDidDisconnectNotification: %@", notification.userInfo[PLTDeviceNotificationKey]);
	self.device = nil;
}

//#pragma mark - PLTDeviceConnectionDelegate
//
//- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
//{
//	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
//}
//
//- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
//{
//	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
//	self.device = nil;
//}
//
//- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
//{
//	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
//	self.device = nil;
//}

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
    [self registerForDeviceNotifications];
    
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		//self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
	}
}

@end
