//
//  PLTDevice_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//


@class PLTDevice;

#ifdef TARGET_IOS
@class EAAccessory;
#endif

@interface PLTDevice()

#ifdef TARGET_OSX
- (PLTDevice *)initWithBluetoothAddress:(NSString *)address;
#endif

#ifdef TARGET_IOS
- (PLTDevice *)initWithAccessory:(EAAccessory *)anAccessory;
#endif

#ifdef TARGET_IOS
@property(nonatomic,strong)		EAAccessory		*accessory;
#endif

@end
