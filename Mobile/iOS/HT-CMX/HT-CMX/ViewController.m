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


#import "HeatMapView.h"


#define HEAT_MAP_TIMER_RATE		100.0 // Hz


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
- (void)rebuildStartStopButton:(BOOL)started;
- (void)rebuildScrollView;
- (void)centerScrollView;
- (void)settingsButton:(id)sender;
- (void)startDemo:(id)sender;
- (void)stopDemo:(id)sender;
- (void)orientationTrackingInfoDidChange:(PLTOrientationTrackingInfo *)theInfo;
- (void)wearingStateInfoDidChange:(PLTWearingStateInfo *)theInfo;

@property(nonatomic, strong)	PLTDevice				*device;
@property(nonatomic, assign)	CGPoint					baseContentOffset;
@property(nonatomic, assign)	BOOL					deviceDonned;
@property(nonatomic, assign)	BOOL					demoStarted;
@property(nonatomic, strong)	UIPopoverController		*settingsPopoverController;
@property(nonatomic, strong)	NSMutableDictionary		*heatMapPoints;
@property(nonatomic, strong)	IBOutlet UIScrollView	*scrollView;


@property(nonatomic, strong)	UIImageView				*imageView;
@property(nonatomic, strong)	HeatMapView				*heatMapView;

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

- (void)rebuildStartStopButton:(BOOL)started
{
	NSString *title = @"Start";
	SEL action = @selector(startDemo:);
	if (started) {
		title = @"Stop";
		action = @selector(stopDemo:);
	}
	
	UIBarButtonItem *startItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:action];
	self.navigationItem.leftBarButtonItem = startItem;
}

- (void)rebuildScrollView
{
	NSLog(@"rebuildScrollView");
	
	// setup scroll view
	
	CGFloat SCALE = [DEFAULTS floatForKey:PLTDefaultsKeyScale];
	
	NSString *imageName = [NSString stringWithFormat:@"%@.png", [DEFAULTS objectForKey:PLTDefaultsKeyImage]];
	self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	for (UIView *subview in self.scrollView.subviews) {
		[subview removeFromSuperview];
	}
	
	self.scrollView.frame = self.view.frame;
	self.scrollView.contentOffset = CGPointZero;
	CGRect imageViewFrame = self.imageView.frame;
	imageViewFrame.size = CGSizeMake(self.imageView.frame.size.width * SCALE, self.imageView.frame.size.height * SCALE);
	self.imageView.frame = imageViewFrame;
	self.scrollView.contentSize = self.imageView.frame.size;
	[self.scrollView addSubview:self.imageView];
	self.scrollView.backgroundColor = [UIColor blackColor];
	
	CGFloat widthDiff = self.scrollView.frame.size.width - self.scrollView.contentSize.width;
	CGFloat heightDiff = self.scrollView.frame.size.height - self.scrollView.contentSize.height;
	
	self.baseContentOffset = CGPointMake(self.scrollView.contentOffset.x - (widthDiff/2.0),
										 self.scrollView.contentOffset.y - (heightDiff/2.0));
	[self centerScrollView];
	
	PLTOrientationTrackingInfo *cachedInfo = (PLTOrientationTrackingInfo *)[self.device cachedInfoForService:PLTServiceOrientationTracking];
	if (cachedInfo) {
		[self orientationTrackingInfoDidChange:cachedInfo];
	}
}

- (void)centerScrollView
{
	self.scrollView.contentOffset = self.baseContentOffset;
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

- (void)startDemo:(id)sender
{
	NSLog(@"startDemo:");
	
	if (!self.demoStarted) {
		self.demoStarted = YES;
	
		[self rebuildStartStopButton:YES];
		[self centerScrollView];
		[self rebuildScrollView];
		
		self.heatMapPoints = [NSMutableDictionary dictionary];
		
		// subscribe to orientation tracking
		NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
		if (err) NSLog(@"Error: %@", err);
		
		// zero's orientation tracking
		[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
	}
}

- (void)stopDemo:(id)sender
{
	NSLog(@"stopDemo:");
	
	if (self.demoStarted) {
		self.demoStarted = NO;
		
		[self rebuildStartStopButton:NO];
		
		if ([DEFAULTS boolForKey:PLTDefaultsKeyHeatMap]) {
			
			// scale the heat map points down to the full image (on-screen) size
			CGFloat heatScaleX = self.view.frame.size.width / self.imageView.frame.size.width;
			CGFloat heatScaleY = self.view.frame.size.height / self.imageView.frame.size.height;
			NSMutableDictionary *newHeatMapPoints = [NSMutableDictionary dictionary];
			for (NSValue *v in self.heatMapPoints) {
				CGPoint oldPoint;
				[v getValue:&oldPoint];
				
				CGPoint newPoint = CGPointMake(oldPoint.x * heatScaleX,
											   oldPoint.y * heatScaleY);
				
				NSValue *newValue = [NSValue value:&newPoint withObjCType:@encode(CGPoint)];
				[newHeatMapPoints setObject:[NSNumber numberWithInt:1] forKey:newValue];
			}
			//self.heatMapPoints = newHeatMapPoints;
			
			// create heat map
			self.heatMapView = [[HeatMapView alloc] initWithFrame:self.imageView.frame];
			self.heatMapView.alpha = 0;
			[self.heatMapView setData:newHeatMapPoints];
			[self.imageView addSubview:self.heatMapView];
			
			[UIView animateWithDuration:1.5 animations:^{
				self.scrollView.contentSize = self.view.frame.size;
				self.imageView.frame = self.scrollView.frame;
				self.heatMapView.frame = self.scrollView.frame;
				
			}];
			
			[UIView animateWithDuration:1.0 delay:.5 options:0 animations:^{
				self.heatMapView.alpha = 1;
			} completion:nil];
		}
		else {
			[self centerScrollView];
		}
	}
}

- (void)orientationTrackingInfoDidChange:(PLTOrientationTrackingInfo *)theInfo
{
	if (self.demoStarted && self.deviceDonned) {
		PLTEulerAngles eulerAngles = theInfo.eulerAngles;
		
		CGFloat DISTANCE = [DEFAULTS doubleForKey:PLTDefaultsKeySensitivity];
		CGFloat SCALE = [DEFAULTS floatForKey:PLTDefaultsKeyScale];
		
		// stop wrap-around, and extreme offset values
		if (eulerAngles.x > 85) {
			eulerAngles.x = 85;
		}
		else if (eulerAngles.x < -85) {
			eulerAngles.x = -85;
		}
		if (eulerAngles.y > 85) {
			eulerAngles.y = 85;
		}
		else if (eulerAngles.y < -85) {
			eulerAngles.y = -85;
		}
		
		CGFloat xOffset = (DISTANCE * tan(d2r(-eulerAngles.x))) * SCALE;
		CGFloat yOffset = (DISTANCE * tan(d2r(-eulerAngles.y))) * SCALE;
		
		
		// save the heat map points -- notice they are saved before clipping based on base offset
		CGPoint heatMapPoint = CGPointMake(xOffset + self.baseContentOffset.x + self.scrollView.frame.size.width/2.0,
										   yOffset + self.baseContentOffset.y + self.scrollView.frame.size.height/2.0);
		NSValue *pointValue = [NSValue value:&heatMapPoint withObjCType:@encode(CGPoint)];
        [self.heatMapPoints setObject:[NSNumber numberWithInt:1] forKey:pointValue];
		

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
		
//		NSLog(@"cententSize: %@", NSStringFromCGSize(self.scrollView.contentSize));
//		NSLog(@"imageView.frame: %@", NSStringFromCGRect(self.imageView.frame));
//		NSLog(@"baseContentOffset: %@", NSStringFromCGPoint(self.baseContentOffset));
//		NSLog(@"angle.x: %.1f,\tangle.y: %.1f", eulerAngles.x, eulerAngles.y);
//		NSLog(@"xOffset: %.1f,\tyOffset: %.1f", xOffset, yOffset);

		CGPoint newOffset = CGPointMake(self.baseContentOffset.x + xOffset , self.baseContentOffset.y + yOffset);
		//NSLog(@"newOffset: { %.1f, %.1f }", newOffset.x, newOffset.y);
		
		[self.scrollView setContentOffset:newOffset animated:[DEFAULTS boolForKey:PLTDefaultsKeySmoothing]];
	}
}

- (void)wearingStateInfoDidChange:(PLTWearingStateInfo *)theInfo
{
	NSLog(@"**************** wearingStateInfoDidChange: %@ ****************", (theInfo.isBeingWorn ? @"YES" : @"NO"));
	
	if (theInfo.isBeingWorn && !self.deviceDonned) {
		// user just donned the HS
		[self startDemo:self];
	}
	else if (!theInfo.isBeingWorn) {
		NSLog(@"Not donned -- Stopping demo.");
		[self stopDemo:self];
	}
	self.deviceDonned = theInfo.isBeingWorn;
}
	
#pragma mark - UIPopoverControllerDelegate
	
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self rebuildScrollView];
}
	
#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewControllerDidChangeValue:(SettingsViewController *)theController
{
	[self rebuildScrollView];
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
	
	err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
//#warning FOR DEBUGGING
//	err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModePeriodic minPeriod:1000];
//	if (err) NSLog(@"Error: %@", err);
	
	[self.device queryInfo:self forService:PLTServiceWearingState];
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
	self.demoStarted = NO;
	self.deviceDonned = NO;
	[self centerScrollView];
}

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
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
	
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.view.backgroundColor = [UIColor blackColor];
	
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
	
	[self rebuildStartStopButton:NO];
	
	UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_icon.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = settingsItem;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//[self rebuildScrollView];
	
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self rebuildScrollView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self rebuildScrollView];
}

@end
