//
//  PLTDevice_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//


#import "PLTDevice.h"


extern NSString *const PLTDeviceWillSendDataNotification;
extern NSString *const PLTDeviceDidReceiveDataNotification;
extern NSString *const PLTDeviceDataNotificationKey;


@protocol BRDeviceDelegate;
@protocol PLTDeviceBRDevicePassthroughDelegate;


@class BRDevice;

#ifdef TARGET_IOS
@class EAAccessory;
#endif


@interface PLTDevice ()

+ (PLTDevice *)deviceWithBRDevice:(BRDevice *)brDevice;

//#ifdef TARGET_OSX
//- (PLTDevice *)initWithBluetoothAddress:(NSString *)address;
//#endif
//
//#ifdef TARGET_IOS
//- (PLTDevice *)initWithAccessory:(EAAccessory *)anAccessory;
//#endif

// this should be readonly here, but in implementation it complains about being already declaired... (because this is a class extension?)
@property(nonatomic,strong,readwrite)	BRDevice									*brDevice;
@property(nonatomic,assign)				id <PLTDeviceBRDevicePassthroughDelegate>	passthroughDelegate;
#ifdef TARGET_IOS
@property(nonatomic,strong)				EAAccessory									*accessory;
#endif

@end


// protocol passes through all BRDeviceDelegate messages 

@protocol PLTDeviceBRDevicePassthroughDelegate <BRDeviceDelegate>

@end
