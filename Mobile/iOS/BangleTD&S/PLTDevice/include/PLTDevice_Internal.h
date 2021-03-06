//
//  PLTDevice_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//


#import "PLTDevice.h"

@class BRDevice;

#ifdef TARGET_IOS
@class EAAccessory;
#endif

@interface PLTDevice ()

#ifdef TARGET_OSX
- (PLTDevice *)initWithBluetoothAddress:(NSString *)address;
#endif

#ifdef TARGET_IOS
- (PLTDevice *)initWithAccessory:(EAAccessory *)anAccessory;
#endif

// this should be readonly here, but in implementation it complains about being already declaired... (because this is a class extension?)
@property(nonatomic,strong,readwrite)	BRDevice		*brDevice;
#ifdef TARGET_IOS
@property(nonatomic,strong)		EAAccessory		*accessory;
#endif




#warning TEMPORARY
- (void)sneakySneaky:(id)subscriber;

@end
