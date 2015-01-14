//
//  SecurityViewController.m
//  CSR Wireless Sensor
//
//  Created by Morgan Davis on 12/10/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import "SecurityViewController.h"
#import "PLTDeviceHandler.h"
#import "Reachability.h"
#import "PLTDevice.h"


@interface SecurityViewController () <PLTDeviceSubscriber>

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;
- (BOOL)checkReachability;

@property(nonatomic,strong)	Reachability	*reachability;
@property(nonatomic,strong)	UIImageView		*reachabilityImageView;

@end


@implementation SecurityViewController

#pragma mark - Private

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self subscribeToServices];
}

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (CONNECTED_DEVICE) {
		NSError *err = nil;
		[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModePeriodic andPeriod:250 error:&err];
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

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	self.title = @"Security";
	self.tabBarItem.title = @"Security";
	self.tabBarItem.image = [UIImage imageNamed:@"lock_icon.png"];
	
	self.reachability = [Reachability reachabilityForInternetConnection];
	[[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		NSLog(@"kReachabilityChangedNotification");
		if ([self checkReachability]) {
			//[self connectOpenTok];
		}
	}];
	[self.reachability startNotifier];
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_ios7.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeCenter;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																	style:UIBarButtonItemStyleBordered
																   target:[UIApplication sharedApplication].delegate
																   action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = settingItem;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.reachabilityImageView.alpha = 0.0;
	
	[self subscribeToServices];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	//[[PLTContextServer sharedContextServer] addDelegate:self];
	
	//[TestFlight passCheckpoint:@"STREETVIEW_TAB"];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.reachabilityImageView) {
		self.reachabilityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		self.reachabilityImageView.contentMode = UIViewContentModeCenter;
		self.reachabilityImageView.image = [UIImage imageNamed:(IPAD ? @"no_internet_ipad.png" : @"no_internet_iphone.png")];
		self.reachabilityImageView.alpha = 0.0;
		[self.view addSubview:self.reachabilityImageView];
	}
	
	if ([self checkReachability]) {
		//[self connectOpenTok];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[self unsubscribeFromServices];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	//[[PLTContextServer sharedContextServer] removeDelegate:self];
}

@end
