//
//  PLTDeviceWatcher.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTDeviceWatcher.h"
#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
#import <IOBluetooth/IOBluetoothUserLib.h>
#import <IOBluetooth/IOBluetooth.h>


NSString *const PLTDeviceProtocolString =					@"com.plt.protocol1";


@interface PLTDeviceWatcher()

- (void)bluetoothDeviceDidConnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)device;
- (void)bluetoothDeviceDidDisconnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)device;
- (void)postDeviceAvailableNotification:(PLTDevice *)device;
- (BOOL)bluetoothDeviceIsWC1:(IOBluetoothDevice *)device;

@property(nonatomic, strong)	NSMutableArray	*devices;
//@property(nonatomic, strong)	NSMutableArray	*connectedBluetoothDevices;

@end


@implementation PLTDeviceWatcher

#pragma mark - API Internal

+ (PLTDeviceWatcher *)sharedWatcher
{
	static PLTDeviceWatcher *watcher = nil;
	if (!watcher) watcher = [[PLTDeviceWatcher alloc] init];
	return watcher;
}

#pragma mark - Private

- (id)init
{
	if (self = [super init]) {
		
        self.devices = [NSMutableArray array];
        
        for (IOBluetoothDevice *d in [IOBluetoothDevice pairedDevices]) {
            if (d.isConnected && [self bluetoothDeviceIsWC1:d]) {
                [d registerForDisconnectNotification:self selector:@selector(bluetoothDeviceDidDisconnectNotification:device:)];
                PLTDevice *device = [[PLTDevice alloc] initWithBluetoothAddress:d.addressString];
                [self.devices addObject:device];
            }
        }
        
        [IOBluetoothDevice registerForConnectNotifications:self selector:@selector(bluetoothDeviceDidConnectNotification:device:)];
    }
	
    return self;
}

- (void)bluetoothDeviceDidConnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)btDevice
{
	NSLog(@"bluetoothDeviceDidConnectNotification: %@", btDevice);
    
    if ([self bluetoothDeviceIsWC1:btDevice]) {
        [btDevice registerForDisconnectNotification:self selector:@selector(bluetoothDeviceDidDisconnectNotification:device:)];
        
//        for (PLTDevice *d in self.devices) {
//            if (![d.bluetoothDevice.addressString isEqualToString:btDevice.addressString]) {
//                
//            }
//            else {
//                NSLog(@"Device already listed!");
//            }
//        }
        
        
		PLTDevice *device = [[PLTDevice alloc] initWithBluetoothAddress:btDevice.addressString];
		if (![self.devices containsObject:device]) {
			[self.devices addObject:device];
			[self postDeviceAvailableNotification:device];
		}
    }
}

- (void)bluetoothDeviceDidDisconnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)btDevice
{
	NSLog(@"bluetoothDeviceDidDisconnectNotification: %@", btDevice);
	
    if ([self bluetoothDeviceIsWC1:btDevice]) { // this is a sanity check since we shouldn't get the disconnect notification if the device wasn't a WC1 in the first place...
		NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
		for (NSUInteger i=0; i<[self.devices count]; i++) {
			PLTDevice *d = self.devices[i];
			if ([d.address isEqualToString:btDevice.addressString]) {
				[toRemove addIndex:i];
				[d closeConnection];
			}
		}
		[self.devices removeObjectsAtIndexes:toRemove];
	}
}
		  
- (void)postDeviceAvailableNotification:(PLTDevice *)device
{
	NSLog(@"postDeviceAvailableNotification: %@", device);
	
	NSDictionary *userInfo = @{ PLTDeviceNotificationKey : device };
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceAvailableNotification object:nil userInfo:userInfo];
}

- (BOOL)bluetoothDeviceIsWC1:(IOBluetoothDevice *)device
{
    for (IOBluetoothSDPServiceRecord *service in device.services) {
#warning CHECK VERSION/TYPE?
        if ([[service getServiceName] isEqualToString:@"PltHeadsetDataService"]) {
            return YES;
        }
    }
    
    return NO;
}

@end
