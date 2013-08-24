//
//  PLTDevice.h
//  PLTDevice
//
//  Created by Davis, Morgan on 8/1/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//


extern NSString *const PLTDeviceDidConnectNotification;
extern NSString *const PLTDeviceDidDisconnectNotification;
extern NSString *const PLTDeviceInfoDidUpdateNotification;
extern NSString *const PLTDeviceHeadTrackingCalibrationDidUpdateNotification;

// keys for device information (identification and sensor information)
extern NSString *const PLTDeviceInfoSerialNumber;
extern NSString *const PLTDeviceInfoQuaternionData;                  // NSData containing PLTVec4 (calibrated)
extern NSString *const PLTDeviceInfoOrientationVectorData;			 // NSData containing PLTVec3 (calibrated)
extern NSString *const PLTDeviceInfoTemperature;                     // NSNumber containing degrees Celcius
extern NSString *const PLTDeviceInfoFreeFall;                        // NSNumber containing boolean
extern NSString *const PLTDeviceInfoPedometerCount;                  // NSNumber
extern NSString *const PLTDeviceInfoTapCount;                        // NSNumber
extern NSString *const PLTDeviceInfoTapDirection;                    // NSNumber containing PLTTapDirection
extern NSString *const PLTDeviceInfoMagnetometerCalibrationStatus;   // NSNumber containing PLTMagnetometerCalibrationStatus
extern NSString *const PLTDeviceInfoGyroscopeCalibrationStatus;      // NSNumber containing PLTGyroscopeCalibrationStatus
extern NSString *const PLTDeviceInfoMajorVersion;                    // NSNumber
extern NSString *const PLTDeviceInfoMinorVersion;                    // NSNumber
extern NSString *const PLTDeviceInfoIsDonned;						 // NSNumber

// the device info update/broadcast "mode" to be used when subscribing to device info
typedef NS_ENUM(NSUInteger, PLTDeviceUpdateMode) {
    PLTDeviceInfoNotificationModeOnChange = 1,
	PLTDeviceInfoNotificationModePeriodic
};

// tap direction bitmap associated with PLTDeviceInfoTapDirection
typedef NS_ENUM(NSUInteger, PLTDeviceTapDirection) {
    PLTDeviceTapDirectionXUp = 1,
    PLTDeviceTapDirectionXDown,
    PLTDeviceTapDirectionYUp,
    PLTDeviceTapDirectionYDown,
    PLTDeviceTapDirectionZUp,
    PLTDeviceTapDirectionZDown
};

// magnetometer calibration status associated with PLTDeviceInfoMagnetometerCalibrationStatus
typedef NS_ENUM(NSUInteger, PLTDeviceMagnetometerCalibrationStatus) {
    PLTDeviceMagnetometerCalibrationStatusNotCalibrated = 0,
    PLTDeviceMagnetometerCalibrationStatusCalibrating1,
    PLTDeviceMagnetometerCalibrationStatusCalibrating2,
    PLTDeviceMagnetometerCalibrationStatusCalibrated
};

// gyroscope calibration status associated with PLTDeviceInfoGyroscopeCalibrationStatus
typedef NS_ENUM(NSUInteger, PLTDeviceGyroscopeCalibrationStatus) {
    PLTDeviceGyroscopeCalibrationStatusNotCalibrated = 0,
    PLTDeviceGyroscopeCalibrationStatusCalibrating1,
    PLTDeviceGyroscopeCalibrationStatusCalibrating2,
    PLTDeviceGyroscopeCalibrationStatusCalibrated
};

// head tracking calibration trigger bitmask associated with headTrackingCalibrationTriggers property
typedef NS_ENUM(NSUInteger, PLTDeviceHeadTrackingCalibrationTrigger) {
    PLTDeviceHeadTrackingCalibrationTriggerShake = 1 << 0,
	PLTDeviceHeadTrackingCalibrationTriggerDon = 1 << 1
};

// used for head tracking orientation vector
typedef struct {
	double x;
	double y;
	double z;
} PLTVec3;

// used for head tracking quaternion
typedef struct {
	double x;
	double y;
	double z;
	double w;
} PLTVec4;

//typedef NS_ENUM(NSUInteger, PLTDeviceModel) {
//	PLTDeviceModelHTVoyager,
//	PLTDeviceModelBaDangle
//};


@interface PLTDevice : NSObject

// subscribes 'observer' to receive notifications at 'updateSelector' for device info 'infoKey' with 'mode'
- (void)subscribeObserver:(id)observer forKey:(NSString *)infoKey withMode:(PLTDeviceUpdateMode)mode atSelector:(SEL)updateSelector;

// subscribes 'observer' to receive notifications at 'updateSelector' for device info keys contained in 'infoKeys' with 'mode'
- (void)subscribeObserver:(id)observer forKeys:(NSArray *)infoKeys withMode:(PLTDeviceUpdateMode)mode atSelector:(SEL)updateSelector;

// subscribes 'observer' to receive notifications at 'updateSelector' for all device info keys with 'mode'
- (void)subscribeObserver:(id)observer withMode:(PLTDeviceUpdateMode)mode atSelector:(SEL)updateSelector;

// unsubscribes 'observer' from info updates for the given 'infoKey'
- (void)unsubscribeObserver:(id)observer fromKey:(NSString *)infoKey;

// unsubscribes 'observer' from info updates for device info keys contained in 'infoKeys'
- (void)unsubscribeObserver:(id)observer fromKeys:(NSArray *)infoKeys;

// unsubscribes 'observer' from all info updates
- (void)unsubscribeObserver:(id)observer;

// uses the current HT quaternion as calibration refernce point
- (void)updateCalibration;

// returns the latest value for the given key
- (id)deviceInfo:(NSString *)infoKey;

// returns all latest device info
- (NSDictionary *)deviceInfo;

// returns YES or NO to indicate if a connection to the deivce is open or not
@property(nonatomic,readonly)   BOOL										isConnected;

// sets/reads a bitmask describing which (currently shake and/or don) events will trigger a automatic HT cal. default is both shake and don.
@property(nonatomic,assign)		PLTDeviceHeadTrackingCalibrationTrigger		headTrackingCalibrationTriggers;

// sets/reads the delay in second to cal after a don event if headTrackingCalibrationTriggers includes PLTDeviceHeadTrackingCalibrationTriggerDon.
@property(nonatomic,assign)		float										donCalibrationDelay;

//@property(nonatomic, readonly)	PLTDeviceModel	model;
@property(nonatomic, readonly)	NSString		*serialNumber;			// the serial number of the device
@property(nonatomic, readonly)	NSString		*firmwareVersion;		// the firmware version running on the device
@property(nonatomic, readonly)	NSString		*hardwareVersion;		// the hardware version of the device
@property(nonatomic, readonly)	NSArray			*deviceCapabilities;	// an arrya containing PLTDeviceInfo keys for information that this device supports

@end
