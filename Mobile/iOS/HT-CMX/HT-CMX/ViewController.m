//
//  ViewController.m
//  HT-CMX
//
//  Created by Davis, Morgan on 10/7/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"


double d2r(double d)
{
	return d * (M_PI/180.0);
}

double r2d(double d)
{
	return d * (180.0/M_PI);
}


@interface ViewController () <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

- (void)newDeviceAvailableNotification:(NSNotification *)notification;
- (void)startButton:(id)sender;

@property(nonatomic, strong)	PLTDevice				*device;
@property(nonatomic, assign)	CGPoint					baseContentOffset;
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

- (void)startButton:(id)sender
{
	// subscribe to orientation tracking
	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	// zero's orientation tracking
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
	
//	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
//	if (err) NSLog(@"Error: %@", err);
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
		
		const CGFloat DISTANCE = 400.0; // screen pixles
		
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
		
		
		NSLog(@"raw offsets: %.1f, %.1f", xOffset, yOffset);

		CGPoint newOffset = CGPointMake(self.baseContentOffset.x + xOffset , self.baseContentOffset.y + yOffset);
		
		NSLog(@"newOffset: { %.1f, %.1f }", newOffset.x, newOffset.y);
		
		
		//[self.scrollView setContentOffset:newOffset animated:YES];
		self.scrollView.contentOffset = newOffset;
	}
}

#pragma mark - UIViewContorller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:@"ViewController" bundle:nil];
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
	self.navigationItem.rightBarButtonItem = startItem;
	
	// setup scroll view
	UIImageView *shelfImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf_plank.jpg"]];
	shelfImageview.contentMode = UIViewContentModeScaleAspectFill;
	
	self.scrollView.contentSize = shelfImageview.frame.size;
	[self.scrollView addSubview:shelfImageview];
	self.scrollView.backgroundColor = [UIColor blackColor];
	
	CGFloat widthDiff = self.scrollView.frame.size.width - self.scrollView.contentSize.width;
	CGFloat heightDiff = self.scrollView.frame.size.height - self.scrollView.contentSize.height;
	self.baseContentOffset = CGPointMake(self.scrollView.contentOffset.x - (widthDiff/2.0),
										 self.scrollView.contentOffset.y - (heightDiff/2.0));
	self.scrollView.contentOffset = self.baseContentOffset;
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

@end
