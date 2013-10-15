//
//  ViewController.m
//  HT-CMX
//
//  Created by Davis, Morgan on 10/7/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"


double d2r(double d)
{
	return d * (M_PI/180.0);
}

double r2d(double d)
{
	return d * (180.0/M_PI);
}


@interface ViewController () <UIPopoverControllerDelegate, PLTDeviceConnectionDelegate, PLTDeviceInfoObserver, SettingsViewControllerDelegate>

- (void)newDeviceAvailableNotification:(NSNotification *)notification;
- (void)setupScrollView;
- (void)settingsButton:(id)sender;
- (void)startButton:(id)sender;
- (void)orientationTrackingInfoDidChange:(PLTOrientationTrackingInfo *)theInfo;
- (void)wearingStateInfoDidChange:(PLTWearingStateInfo *)theInfo;

@property(nonatomic, strong)	PLTDevice				*device;
@property(nonatomic, assign)	CGPoint					baseContentOffset;
@property(nonatomic, assign)	BOOL					deviceDonned;
@property(nonatomic, strong)	UIPopoverController		*settingsPopoverController;
@property(nonatomic, strong)	IBOutlet UIScrollView	*scrollView;

@end


@implementation ViewController

#pragma mark - Private

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
}

- (void)setupScrollView
{
	// setup scroll view
	
	NSString *imageName = [NSString stringWithFormat:@"%@.png", [DEFAULTS objectForKey:PLTDefaultsKeyImage]];
	UIImageView *shelfImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	shelfImageview.contentMode = UIViewContentModeScaleAspectFill;
	
	for (UIView *subview in self.scrollView.subviews) {
		[subview removeFromSuperview];
	}
	
	self.scrollView.frame = self.view.frame;
	self.scrollView.contentOffset = CGPointZero;
	self.scrollView.contentSize = shelfImageview.frame.size;
	[self.scrollView addSubview:shelfImageview];
	self.scrollView.backgroundColor = [UIColor blackColor];
	
	CGFloat widthDiff = self.scrollView.frame.size.width - self.scrollView.contentSize.width;
	CGFloat heightDiff = self.scrollView.frame.size.height - self.scrollView.contentSize.height;
	
	self.baseContentOffset = CGPointMake(self.scrollView.contentOffset.x - (widthDiff/2.0),
										 self.scrollView.contentOffset.y - (heightDiff/2.0));
	self.scrollView.contentOffset = self.baseContentOffset;
	
	PLTOrientationTrackingInfo *cachedInfo = (PLTOrientationTrackingInfo *)[self.device cachedInfoForService:PLTServiceOrientationTracking];
	if (cachedInfo) {
		[self orientationTrackingInfoDidChange:cachedInfo];
	}
}

- (void)settingsButton:(id)sender
{
	if (self.settingsPopoverController.popoverVisible) {
		[self.settingsPopoverController dismissPopoverAnimated:YES];
	}
	else {
		SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
		settingsViewController.delegate = self;
		self.settingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
		self.settingsPopoverController.delegate = self;
		[self.settingsPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void)startButton:(id)sender
{
	NSLog(@"starting headtracking");
	
	// subscribe to orientation tracking
	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	// zero's orientation tracking
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
}

- (void)orientationTrackingInfoDidChange:(PLTOrientationTrackingInfo *)theInfo
{
	if (self.deviceDonned) {
		PLTEulerAngles eulerAngles = theInfo.eulerAngles;
		
		//const CGFloat DISTANCE = 400.0; // screen pixles
		CGFloat DISTANCE = [DEFAULTS doubleForKey:PLTDefaultsKeyHTSensitivity];
		NSLog(@"DISTANCE: %.1f", DISTANCE);
		
		// stop wrap-around, and extreme offset values
		if (eulerAngles.x > 80) {
			eulerAngles.x = 80;
		}
		else if (eulerAngles.x < -80) {
			eulerAngles.x = -80;
		}
		if (eulerAngles.y > 80) {
			eulerAngles.y = 80;
		}
		else if (eulerAngles.y < -80) {
			eulerAngles.y = -80;
		}
		
		CGFloat xOffset = DISTANCE * tan(d2r(-eulerAngles.x));
		CGFloat yOffset = DISTANCE * tan(d2r(-eulerAngles.y));

		// check that we don't scroll past the content's bounds
//		if ((fabs(xOffset) > fabs(self.baseContentOffset.x)) || (fabs(yOffset) > fabs(self.baseContentOffset.y))) {
//			NSLog(@"Offset too large, pinning to content edge.");
//			return;
//		}
	
		if ((xOffset > 0) && (xOffset > self.baseContentOffset.x)) {
			xOffset = self.baseContentOffset.x;
		}
		else if ((xOffset <= 0) && (-xOffset > self.baseContentOffset.x)) {
			xOffset = -self.baseContentOffset.x;
		}
		
		if ((yOffset > 0) && (yOffset > self.baseContentOffset.y)) {
			yOffset = self.baseContentOffset.y;
		}
		else if ((yOffset <= 0) && (-yOffset > self.baseContentOffset.y)) {
			yOffset = -self.baseContentOffset.y;
		}

		CGPoint newOffset = CGPointMake(self.baseContentOffset.x + xOffset , self.baseContentOffset.y + yOffset);
		NSLog(@"newOffset: { %.1f, %.1f }", newOffset.x, newOffset.y);
		
		//[self.scrollView setContentOffset:newOffset animated:YES];
		self.scrollView.contentOffset = newOffset;
	}
}

- (void)wearingStateInfoDidChange:(PLTWearingStateInfo *)theInfo
{
	if (theInfo.isBeingWorn && !self.deviceDonned) {
		// user just donned the HS
		[self startButton:self];
	}
	else if (!theInfo.isBeingWorn) {
		// re-center content
		NSLog(@"not donned -- centering content");
		self.scrollView.contentOffset = self.baseContentOffset;
	}
	self.deviceDonned = theInfo.isBeingWorn;
}
	
#pragma mark - UIPopoverControllerDelegate
	
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self setupScrollView];
}
	
#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewControllerDidChangeValue:(SettingsViewController *)theController
{
	[self setupScrollView];
}

- (void)settingsViewControllerDidEnd:(SettingsViewController *)theController
{
	if (self.settingsPopoverController) {
		[self.settingsPopoverController dismissPopoverAnimated:YES];
	}
}
	
#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
	
	NSError *err = nil;
	
//	err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
//	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
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
		[self orientationTrackingInfoDidChange:(PLTOrientationTrackingInfo *)theInfo];
	}
	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
		[self wearingStateInfoDidChange:(PLTWearingStateInfo *)theInfo];
	}
}

#pragma mark - UIViewContorller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:@"ViewController" bundle:nil];
	self.deviceDonned = NO; // avoid starting if the device is donned at launch
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
	// setup navigation item
	
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"plt_cisco_nav_ios7.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeScaleAspectFill;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *startItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(startButton:)];
	self.navigationItem.leftBarButtonItem = startItem;
	
	UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_icon.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = settingsItem;
	
	
	[self setupScrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self setupScrollView];
}

@end
