//
//  AppDelegate.h
//  WC2 Kit
//
//  Created by Morgan Davis on 12/30/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <UIKit/UIKit.h>


#define DEFAULTS    [NSUserDefaults standardUserDefaults]


extern NSString *const PLTDefaultsKeyDefaultsVersion;
extern NSString *const PLTDefaultsKeyMetricUnits;
extern NSString *const PLTDefaultsKeyOverrideLocations;
extern NSString *const PLTDefaultsKeyOverrideLocationLabel;
extern NSString *const PLTDefaultsKeyOverrideLocationLatitude;
extern NSString *const PLTDefaultsKeyOverrideLocationLongitude;
extern NSString *const PLTDefaultsKeyOverrideSelectedLocation;
extern NSString *const PLTDefaultsKeyHeadGestureRecognition;
extern NSString *const PLTDefaultsKeyHeadMirrorImage;
extern NSString *const PLTDefaultsKeyHTCalibrationTriggers;
//extern NSString *const PLTDefaultsKeySecurityEnabled;
extern NSString *const PLTDefaultsKeySecurityDevice;
extern NSString *const PLTDefaultsKeySecurityDeviceName;
extern NSString *const PLTDefaultsKeySecurityDeviceID;
extern NSString *const PLTDefaultsKeySecurityFIDOUsername;
extern NSString *const PLTDefaultsKeyKubiEnabled;
extern NSString *const PLTDefaultsKeyKubiDevice;
extern NSString *const PLTDefaultsKeyKubiDeviceName;
extern NSString *const PLTDefaultsKeyKubiDeviceTokBoxAPIKey;
extern NSString *const PLTDefaultsKeyKubiDeviceTokBoxSessionID;
extern NSString *const PLTDefaultsKeyKubiDeviceTokBoxPublisherIDiPad;
extern NSString *const PLTDefaultsKeyKubiMode;
extern NSString *const PLTDefaultsKeyKubiMirror;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (void)connectToContextServer;
- (void)registerDeviceWithContextServer;
- (void)settingsButton:(id)sender;

@property(nonatomic,retain) UIWindow *window;

@end
