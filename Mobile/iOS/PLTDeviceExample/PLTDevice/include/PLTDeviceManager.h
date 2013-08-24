//
//  PLTDeviceManager.h
//  PLTDevice
//
//  Created by Davis, Morgan on 7/2/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#define PLT_DEVICE_CONNECTED	[[PLTDeviceManager sharedManager] isConnected]

extern NSString *const PLTDeviceDidConnectNotification;
extern NSString *const PLTDeviceDidDisconnectNotification;
extern NSString *const PLTDeviceInfoDidUpdateNotification;
extern NSString *const PLTDeviceHeadTrackingCalibrationDidUpdateNotification;

// keys for latestInfo and notification info
extern NSString *const PLTDeviceInfoKeyQuaternionData;                  // NSData containing Vec4 (calibrated)
extern NSString *const PLTDeviceInfoKeyOrientationVectorData;			// NSData containing Vec3 (calibrated)
extern NSString *const PLTDeviceInfoKeyTemperature;                     // NSNumber containing degrees Celcius
extern NSString *const PLTDeviceInfoKeyFreeFall;                        // NSNumber containing boolean
extern NSString *const PLTDeviceInfoKeyPedometerCount;                  // NSNumber
extern NSString *const PLTDeviceInfoKeyTapCount;                        // NSNumber
extern NSString *const PLTDeviceInfoKeyTapDirection;                    // NSNumber containing PLTTapDirection
extern NSString *const PLTDeviceInfoKeyMagnetometerCalibrationStatus;   // NSNumber containing PLTMagnetometerCalibrationStatus
extern NSString *const PLTDeviceInfoKeyGyroscopeCalibrationStatus;      // NSNumber containing PLTGyroscopeCalibrationStatus
extern NSString *const PLTDeviceInfoKeyMajorVersion;                    // NSNumber
extern NSString *const PLTDeviceInfoKeyMinorVersion;                    // NSNumber
extern NSString *const PLTDeviceInfoKeyIsDonned;						// NSNumber

typedef NS_ENUM(NSUInteger, PLTDeviceTapDirection) {
    PLTDeviceTapDirectionXUp = 1,
    PLTDeviceTapDirectionXDown,
    PLTDeviceTapDirectionYUp,
    PLTDeviceTapDirectionYDown,
    PLTDeviceTapDirectionZUp,
    PLTDeviceTapDirectionZDown
};

typedef NS_ENUM(NSUInteger, PLTDeviceMagnetometerCalibrationStatus) {
    PLTDeviceMagnetometerCalibrationStatusNotCalibrated = 0,
    PLTDeviceMagnetometerCalibrationStatusCalibrating1,
    PLTDeviceMagnetometerCalibrationStatusCalibrating2,
    PLTDeviceMagnetometerCalibrationStatusCalibrated
};

typedef NS_ENUM(NSUInteger, PLTDeviceGyroscopeCalibrationStatus) {
    PLTDeviceGyroscopeCalibrationStatusNotCalibrated = 0,
    PLTDeviceGyroscopeCalibrationStatusCalibrating1,
    PLTDeviceGyroscopeCalibrationStatusCalibrating2,
    PLTDeviceGyroscopeCalibrationStatusCalibrated
};

typedef NS_ENUM(NSUInteger, PLTDeviceHeadTrackingCalibrationTrigger) {
    PLTDeviceHeadTrackingCalibrationTriggerShake = 1 << 0,
	PLTDeviceHeadTrackingCalibrationTriggerDon = 1 << 1
};

typedef struct {
	double x;
	double y;
} Vec2;

typedef struct {
	double x;
	double y;
	double z;
} Vec3;

typedef struct {
	double x;
	double y;
	double z;
	double w;
} Vec4;


@interface PLTDeviceManager : NSObject

+ (PLTDeviceManager *)sharedManager;

@property(nonatomic,readonly)   BOOL            isConnected;
@property(nonatomic,readonly)   NSDictionary    *latestInfo;
@property(nonatomic,assign)		NSUInteger		headTrackingCalibrationTriggers; // bitmask
@property(nonatomic,assign)		float			donCalibrationDelay; // in seconds

@end

