//
//  PLTDevice_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//


@class PLTDevice;
@class IOBluetoothDevice;


@interface PLTDevice()

- (PLTDevice *)initWithBluetoothAddress:(NSString *)address;

//@property(nonatomic, retain)	IOBluetoothDevice		*bluetoothDevice;

@end
