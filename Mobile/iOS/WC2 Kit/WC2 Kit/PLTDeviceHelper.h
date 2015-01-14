//
//  PLTDeviceHelper.h
//

#import <Foundation/Foundation.h>


#define HEADSET_CONNECTED [[PLTDeviceHelper sharedHelper] connectedDevice]
#define CONNECTED_DEVICE [[PLTDeviceHelper sharedHelper] connectedDevice]


extern NSString *const PLTDeviceHandlerDidCalibrateOrientationNotification;


@class PLTDevice;


typedef NS_ENUM(NSUInteger, PLTHeadTrackingCalibrationTrigger) {
    PLTHeadTrackingCalibrationTriggerShake = 1 << 0,
	PLTHeadTrackingCalibrationTriggerDon = 1 << 1
};


@interface PLTDeviceHelper : NSObject

+ (PLTDeviceHelper *)sharedHelper;
- (PLTDevice *)connectedDevice;

@property(nonatomic,assign)		NSUInteger		headTrackingCalibrationTriggers; // bitmask

@end
