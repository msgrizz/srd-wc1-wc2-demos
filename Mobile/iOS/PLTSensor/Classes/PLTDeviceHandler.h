//
//  PLTDeviceHandler.h
//

#import <Foundation/Foundation.h>


#define HEADSET_CONNECTED [[PLTDeviceHandler sharedHandler] connectedDevice]
#define CONNECTED_DEVICE [[PLTDeviceHandler sharedHandler] connectedDevice]


@class PLTDevice;


typedef NS_ENUM(NSUInteger, PLTHeadTrackingCalibrationTrigger) {
    PLTHeadTrackingCalibrationTriggerShake = 1 << 0,
	PLTHeadTrackingCalibrationTriggerDon = 1 << 1
};


@interface PLTDeviceHandler : NSObject

+ (PLTDeviceHandler *)sharedHandler;
- (PLTDevice *)connectedDevice;

@property(nonatomic,assign)		NSUInteger		headTrackingCalibrationTriggers; // bitmask

@end
