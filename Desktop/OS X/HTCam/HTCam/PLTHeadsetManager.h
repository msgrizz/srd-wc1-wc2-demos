//
//  PLTHeadsetManager.h
//
//  Created by Davis, Morgan on 3/27/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//
//  *************************
//  Stripped-down version of "normal" PLTHeadsetManager that doesn't include the ability to actually connect to a headset.
//  *************************
//

#import <Foundation/Foundation.h>


#define HEADSET_CONNECTED	[[PLTHeadsetManager sharedManager] isConnected]

extern NSString *const PLTHeadsetDidConnectNotification;
extern NSString *const PLTHeadsetDidDisconnectNotification;
extern NSString *const PLTHeadsetInfoDidUpdateNotification;
extern NSString *const PLTHeadsetHeadTrackingCalibrationDidUpdateNotification;

// keys for latestInfo and notification info
extern NSString *const PLTHeadsetInfoKeyPacketData;                      // NSData containing raw 23-byte packet (not calibrated)
extern NSString *const PLTHeadsetInfoKeyCalibratedPacketData;		     // NSData containing raw 23-byte packet (calibrated)
extern NSString *const PLTHeadsetInfoKeyQuaternionData;                  // NSData containing Vec4 (calibrated)
extern NSString *const PLTHeadsetInfoKeyRotationVectorData;			     // NSData containing Vec3 (calibrated)
extern NSString *const PLTHeadsetInfoKeyTemperature;                     // NSNumber containing degrees Celcius
extern NSString *const PLTHeadsetInfoKeyFreeFall;                        // NSNumber containing boolean
extern NSString *const PLTHeadsetInfoKeyPedometerCount;                  // NSNumber
extern NSString *const PLTHeadsetInfoKeyTapCount;                        // NSNumber
extern NSString *const PLTHeadsetInfoKeyTapDirection;                    // NSNumber containing PLTTapDirection
extern NSString *const PLTHeadsetInfoKeyMagnetometerCalibrationStatus;   // NSNumber containing PLTMagnetometerCalibrationStatus
extern NSString *const PLTHeadsetInfoKeyGyroscopeCalibrationStatus;      // NSNumber containing PLTGyroscopeCalibrationStatus
extern NSString *const PLTHeadsetInfoKeyMajorVersion;                    // NSNumber
extern NSString *const PLTHeadsetInfoKeyMinorVersion;                    // NSNumber
extern NSString *const PLTHeadsetInfoKeyIsDonned;						 // NSNumber

extern NSString *const PLTHeadsetHeadTrackingKeyCalibrationPacket;		 // NSData containing Vec4


typedef NS_ENUM(NSUInteger, PLTTapDirection) {
    PLTTapDirectionXUp = 1,
    PLTTapDirectionXDown,
    PLTTapDirectionYUp,
    PLTTapDirectionYDown,
    PLTTapDirectionZUp,
    PLTTapDirectionZDown
};

typedef NS_ENUM(NSUInteger, PLTMagnetometerCalibrationStatus) {
    PLTMagnetometerCalibrationStatusNotCalibrated = 0,
    PLTMagnetometerCalibrationStatusCalibrating1,
    PLTMagnetometerCalibrationStatusCalibrating2,
    PLTMagnetometerCalibrationStatusCalibrated
};

typedef NS_ENUM(NSUInteger, PLTGyroscopeCalibrationStatus) {
    PLTGyroscopeCalibrationStatusNotCalibrated = 0,
    PLTGyroscopeCalibrationStatusCalibrating1,
    PLTGyroscopeCalibrationStatusCalibrating2,
    PLTGyroscopeCalibrationStatusCalibrated
};

typedef NS_ENUM(NSUInteger, PLTHeadTrackingCalibrationTrigger) {
    PLTHeadTrackingCalibrationTriggerShake = 1 << 0,
	PLTHeadTrackingCalibrationTriggerDon = 1 << 1
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


@interface PLTHeadsetManager : NSObject

+ (PLTHeadsetManager *)sharedManager;
- (NSDictionary *)infoFromPacketData:(NSData *)packetData;

@property(nonatomic,readonly)   BOOL            isConnected;
@property(nonatomic,readonly)   NSDictionary    *latestInfo;
@property(nonatomic,assign)		NSUInteger		headTrackingCalibrationTriggers; // bitmask

@end
