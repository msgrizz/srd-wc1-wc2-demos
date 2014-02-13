//
//  StreetView2ViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 2/5/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//


#import "StreetView2ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "PLTContextServer.h"
#import "PLTHeadsetManager.h"
#import "LocationMonitor.h"
#import "NSData+Base64.h"


#define CAMERA_FOV						80.0


@interface StreetView2ViewController () <PLTContextServerDelegate, GMSPanoramaViewDelegate>

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note;
- (void)headsetInfoDidUpdate:(NSDictionary *)info;

@property(nonatomic,strong) GMSPanoramaView     *panoramaView;
@property(nonatomic,assign) BOOL                panoramaConfigured;

@end


@implementation StreetView2ViewController

#pragma mark - Private

- (void)locationButton:(id)sender
{
    CLLocationCoordinate2D location = [LocationMonitor sharedMonitor].location.coordinate;
    [self.panoramaView moveNearCoordinate:location];
}

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
    [self headsetInfoDidUpdate:note.userInfo];
}

- (void)headsetInfoDidUpdate:(NSDictionary *)info
{
    NSData *rotationVectorData = info[PLTHeadsetInfoKeyRotationVectorData];
    Vec3 rotationVector;
    [rotationVectorData getBytes:&rotationVector length:[rotationVectorData length]];
    GMSPanoramaCamera *camera = [GMSPanoramaCamera cameraWithHeading:rotationVector.x pitch:rotationVector.y zoom:1.0 FOV:CAMERA_FOV];
    self.panoramaView.camera = camera;
    //[self.panoramaView animateToCamera:camera animationDuration:.05];
}

#pragma mark - GMSPanoramaViewDelegate

- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama
{
    if (!self.panoramaConfigured) {
        self.panoramaView.camera = [GMSPanoramaCamera cameraWithHeading:0 pitch:0 zoom:1.0];
        self.panoramaConfigured = YES;
    }
}

- (BOOL)panoramaView:(GMSPanoramaView *)panoramaView didTapMarker:(GMSMarker *)marker
{
    return YES;
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
    if (!HEADSET_CONNECTED) {
        if ([message hasType:@"event"]) {
			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
                NSDictionary *info = [[PLTHeadsetManager sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
				if (info) {
					[self headsetInfoDidUpdate:info];
				}
            }
        }
    }
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.title = @"Street View";
    self.tabBarItem.title = @"Street View";
    self.tabBarItem.image = [UIImage imageNamed:@"buildings_icon.png"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.panoramaView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:[LocationMonitor sharedMonitor].location.coordinate];
    self.panoramaView.backgroundColor = [UIColor grayColor];
    self.panoramaView.delegate = self;
    self.panoramaView.orientationGestures = NO;
    self.panoramaView.zoomGestures = NO;
    self.view = self.panoramaView;
    
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
	
	UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																   style:UIBarButtonItemStyleBordered
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = settingItem;
    
    UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"locationIcon.png"]
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(locationButton:)];
	self.navigationItem.leftBarButtonItem = locationItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
    [[PLTContextServer sharedContextServer] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PLTHeadsetInfoDidUpdateNotification object:nil];
    [[PLTContextServer sharedContextServer] removeDelegate:self];
}

@end
