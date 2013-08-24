//
//  CSR_Wireless_SensorAppDelegate.h
//  CSR Wireless Sensor
//
//  Copyright Cambridge Silicon Radio Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>


#define DEFAULTS    [NSUserDefaults standardUserDefaults]


extern NSString *const PLTDefaultsKeyDefaultsVersion;
extern NSString *const PLTDefaultsKeyContextServerAddress;
extern NSString *const PLTDefaultsKeyContextServerPort;
extern NSString *const PLTDefaultsKeyContextServerSecureSockets;
extern NSString *const PLTDefaultsKeyContextServerUsername;
extern NSString *const PLTDefaultsKeyContextServerPassword;
extern NSString *const PLTDefaultsKeyContextServerAutoConnect;
extern NSString *const PLTDefaultsKeyContextServerAutoRegister;
extern NSString *const PLTDefaultsKeyShowStatusIcons;
extern NSString *const PLTDefaultsKeyMetricUnits;
extern NSString *const PLTDefaultsKeyGestureRecognition;
extern NSString *const PLTDefaultsKeyOverrideLocations;
    extern NSString *const PLTDefaultsKeyOverrideLocationLabel;
    extern NSString *const PLTDefaultsKeyOverrideLocationLatitude;
    extern NSString *const PLTDefaultsKeyOverrideLocationLongitude;
	extern NSString *const PLTDefaultsKeyOverrideLocationStreetViewPrecacheRoundingMultiple;
	extern NSString *const PLTDefaultsKeyOverrideLocationAskedPrecacheStreetViewRoundingMultiple;
extern NSString *const PLTDefaultsKeyOverrideSelectedLocation;
extern NSString *const PLTDefaultsKey3DHeadMirrorImage;
extern NSString *const PLTDefaultsKey3DHeadDebugOverlay;
extern NSString *const PLTDefaultsKeyStreetViewInfoOverlay;
extern NSString *const PLTDefaultsKeyStreetViewDebugOverlay;
extern NSString *const PLTDefaultsKeyStreetViewRoundingMultiple;
extern NSString *const PLTDefaultsKeyTemperatureOffsetCelcius;
extern NSString *const PLTDefaultsKeySendOldSkewlEvents;
extern NSString *const PLTDefaultsKeyHeadTrackingCalibrationTriggers;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (void)connectToContextServer;
- (void)registerDeviceWithContextServer;
- (void)settingsButton:(id)sender;

@property(nonatomic,retain) UIWindow *window;

@end

