//
//  PLT3DViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 11/5/12.
//  Copyright (c) 2012 Cambridge Silicon Radio. All rights reserved.
//

#import "PLT3DViewController.h"
#import "GLGravityView.h"
#import "UIDevice+ScreenSize.h"
#import "PLTHeadsetManager.h"
#import "CC3Foundation.h"
#import "iToast.h"
#import "PLTContextServer.h"
#import "NSData+Base64.h"
#import "StatusWatcher.h"
#import "AppDelegate.h"


typedef enum {
    GEST_START,
    GEST_ARM,
    GEST_UP,
    GEST_LEFT,
    GEST_YES,
    GEST_NO
} gesture_states;


@interface PLT3DViewController () <PLTContextServerDelegate>

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note;
- (void)gestureCheck:(long long)thetime noplane:(double) theta yesplane:(double)psi;

@property(nonatomic,strong) IBOutlet GLGravityView      *threeDeeView;
@property(nonatomic,assign) double                      theta_ave;
@property(nonatomic,assign) double                      psi_ave;
@property(nonatomic,assign) long long                   oldtime;
@property(nonatomic,assign) gesture_states              gesture_state;

@end


@implementation PLT3DViewController

#pragma mark - Private

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
    //if (![HeadsetManager sharedManager].isConnected || !DEVICE_REGISTERED) {
        Vec4 quaternion;
        NSData *quaternionData = [note userInfo][PLTHeadsetInfoKeyQuaternionData];
        [quaternionData getBytes:&quaternion length:[quaternionData length]];
        [self.threeDeeView updateRotation:quaternion];
	
	if ([DEFAULTS boolForKey:PLTDefaultsKeyGestureRecognition]) {
		Vec3 rotationVector;
        NSData *rotationVectorData = [note userInfo][PLTHeadsetInfoKeyRotationVectorData];
        [rotationVectorData getBytes:&rotationVector length:[rotationVectorData length]];
		[self gestureCheck:(long long)(1000*[[NSDate date] timeIntervalSince1970]) noplane:rotationVector.y yesplane:rotationVector.z];
	}
    //}
}

- (void)gestureCheck:(long long)thetime noplane:(double) theta yesplane:(double)psi
{
	if (self.tabBarController.selectedViewController == self) { // face is selected
        self.theta_ave = self.theta_ave * .8 + theta * .2;
        self.psi_ave = self.psi_ave * .8 + psi * .2;
        
        if ((thetime - self.oldtime) > 5000 || (thetime - self.oldtime) < 0)
            self.oldtime = thetime;
        
        if ((thetime - self.oldtime) > 2000 && (self.gesture_state == GEST_UP || self.gesture_state == GEST_LEFT))
        {
            self.gesture_state = GEST_START;
            self.oldtime = thetime;
            
        }
        else if ((thetime - self.oldtime) > 2000 && (self.gesture_state == GEST_YES || self.gesture_state == GEST_NO))
        {
            self.gesture_state = GEST_START;
            self.oldtime = thetime;
            
        }
        else if (((theta - self.theta_ave) < -8) && (self.gesture_state == GEST_START))
        {
            self.gesture_state = GEST_UP;
            self.oldtime = thetime;
        }
        else if ((theta - self.theta_ave) > 8 && ((thetime - self.oldtime) < 1000) && (self.gesture_state == GEST_UP))
        {
            self.gesture_state = GEST_YES;
            self.oldtime = thetime;
            [[iToast makeText:NSLocalizedString(@"\"Yes\" Detected", @"")] show];
            
            
        }
        else if (((psi - self.psi_ave) < -8) && (self.gesture_state == GEST_START))
        {
            self.gesture_state = GEST_LEFT;
            self.oldtime = thetime;
        }
        else if ((psi - self.psi_ave) > 8 && ((thetime - self.oldtime) < 1000) && (self.gesture_state == GEST_LEFT))
        {
            self.gesture_state = GEST_NO;
            self.oldtime = thetime;
            [[iToast makeText:NSLocalizedString(@"\"No\" Detected", @"")] show];
        }
    }
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
	if (!HEADSET_CONNECTED) {
        if ([message hasType:@"event"]) {
			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
				NSDictionary *info = [[PLTHeadsetManager sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
				if (info) {
					NSData *quaternionData = info[PLTHeadsetInfoKeyQuaternionData];
					Vec4 quaternion;
					[quaternionData getBytes:&quaternion length:[quaternionData length]];
					[self.threeDeeView updateRotation:quaternion];
				}
            }
        }
    }
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        if (IPHONE5) self = [super initWithNibName:@"PL3DViewController_iPhone5" bundle:nibBundleOrNil];
		else self = [super initWithNibName:@"PL3DViewController_iPhone4" bundle:nibBundleOrNil];
    else
        self = [super initWithNibName:@"PL3DViewController_iPad" bundle:nibBundleOrNil];

    self.title = @"Head";
    self.tabBarItem.image = [UIImage imageNamed:@"head_icon.png"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// setup navigation item
	
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_ios7.png"];//[UIImage imageNamed:@"plt_logo_nav.png"];
	if (!IOS7) pltImage = [UIImage imageNamed:@"pltlabs_nav.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeCenter;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																   style:UIBarButtonItemStyleBordered
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = actionItem;
//	}
//	else {
//		self.navigationController.navigationBarHidden = YES;
//		
//		UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav.png"];//[UIImage imageNamed:@"plt_logo_nav.png"];
//		CGRect navFrame = self.navBar.frame;
//		CGRect viewFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
//									  (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
//									  pltImage.size.width + 2,
//									  pltImage.size.height + 2);
//		
//		UIImageView *view = [[UIImageView alloc] initWithFrame:viewFrame];
//		view.contentMode = UIViewContentModeCenter;
//		view.image = pltImage;
//		[self.navBar addSubview:view];
//		
//		UIImage *barImage = [UIImage imageNamed:@"cogBarButton.png"];
//		UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:barImage
//																	   style:UIBarButtonItemStyleBordered
//																	  target:[UIApplication sharedApplication].delegate
//																	  action:@selector(settingsButton:)];
//		((UINavigationItem *)self.navBar.items[0]).rightBarButtonItem = actionItem;
//	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#warning navBar
	[[StatusWatcher sharedWatcher] setActiveNavigationBar:self.navigationController.navigationBar animated:NO];
    [[PLTContextServer sharedContextServer] addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//	[super viewDidAppear:animated];
//	
//	if (!IPHONE5) {
//		CGRect newFrame = CGRectMake(self.threeDeeView.frame.origin.x,
//									 self.threeDeeView.frame.origin.y + 88,
//									 self.threeDeeView.frame.size.width,
//									 self.threeDeeView.frame.size.height - 88);
//		[self.threeDeeView setFrame:newFrame];
//	}
//}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[PLTContextServer sharedContextServer] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PLTHeadsetInfoDidUpdateNotification object:nil];
}

@end
