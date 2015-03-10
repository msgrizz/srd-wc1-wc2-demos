//
//  BRDeviceWatcher.m
//  BRDevice
//
//  Created by Morgan Davis on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "BRDeviceWatcher.h"
#import "BRDevice.h"
#import "BRDeviceUtilities.h"
#import "PLTDLog.h"

#ifdef TARGET_OSX
#import <IOBluetooth/IOBluetoothUserLib.h>
#import <IOBluetooth/IOBluetooth.h>
#endif
#ifdef TARGET_IOS
#import <ExternalAccessory/ExternalAccessory.h>
#endif


#ifdef TARGET_OSX
NSString *const PLTBladerunnerUUIDString =					@"82972387-294e-4d62-97b5-2668aa35f618";
#endif
#ifdef TARGET_IOS
NSString *const PLTDeviceEAProtocolString =					@"com.plantronics.headsetdataservice";
#endif


@interface BRDeviceWatcher()

- (void)postDeviceDidAppearNotification:(BRDevice *)device;
- (void)postDeviceDidDisappearNotification:(BRDevice *)device;

#ifdef TARGET_OSX
- (void)bluetoothDeviceDidConnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)device;
- (void)bluetoothDeviceDidDisconnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)device;
- (BOOL)bluetoothDeviceSpeaksBladerunner:(IOBluetoothDevice *)device;
#endif

#ifdef TARGET_IOS
- (void)accessoryDidConnectNotification:(NSNotification *)notification;
- (void)accessoryDidDisconnectNotification:(NSNotification *)notification;
#endif

@property(nonatomic, strong)	NSMutableArray	*devices;

#ifdef TARGET_OSX
@property(nonatomic, strong)	NSString	*lastDisconnectedDeviceAddress; // work-around for IOBluetooth sometimes posting duplicate disconnect notifications
#endif

@end


@implementation BRDeviceWatcher

#pragma mark - API Internal

+ (BRDeviceWatcher *)sharedWatcher
{
	static BRDeviceWatcher *watcher = nil;
	if (!watcher) watcher = [[BRDeviceWatcher alloc] init];
	return watcher;
}

#pragma mark - Private

- (id)init
{
	if (self = [super init]) {
		
        self.devices = [NSMutableArray array];
		
#ifdef TARGET_OSX
        for (IOBluetoothDevice *d in [IOBluetoothDevice pairedDevices]) {
            if (d.isConnected && [self bluetoothDeviceSpeaksBladerunner:d]) {
                [d registerForDisconnectNotification:self selector:@selector(bluetoothDeviceDidDisconnectNotification:device:)];
				BRDevice *device = [BRDevice deviceWithAddress:d.addressString];
                [self.devices addObject:device];
            }
        }
		
		[IOBluetoothDevice registerForConnectNotifications:self selector:@selector(bluetoothDeviceDidConnectNotification:device:)];
#endif
		
#ifdef TARGET_IOS
		NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
		DLog(DLogLevelInfo, @"Connected accessories:");
		for (EAAccessory *a in accessories) {
			NSLog(@"%p, name: %@, serial: %@, connected: %@", a, a.name, a.serialNumber, (a.connected ? @"YES" : @"NO"));
		}
		for (EAAccessory *a in accessories) {
			BRDevice *device = [BRDevice deviceWithAccessory:a];
			[self.devices addObject:device];
		}
		
		[[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnectNotification:) name:EAAccessoryDidConnectNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnectNotification:) name:EAAccessoryDidDisconnectNotification object:nil];
#endif
    }
	
    return self;
}

#ifdef TARGET_OSX
- (void)bluetoothDeviceDidConnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)btDevice
{
	DLog(DLogLevelInfo, @"bluetoothDeviceDidConnectNotification: %@", btDevice);
    
    if ([self bluetoothDeviceSpeaksBladerunner:btDevice]) {
		self.lastDisconnectedDeviceAddress = nil;
        [btDevice registerForDisconnectNotification:self selector:@selector(bluetoothDeviceDidDisconnectNotification:device:)];
		
//		PLTDevice *device = [[PLTDevice alloc] initWithBluetoothAddress:btDevice.addressString];
//		if (![self.devices containsObject:device]) {
//			[self.devices addObject:device];
//			[self postDeviceAvailableNotification:device];
//		}
		
		BRDevice *device = [BRDevice deviceWithAddress:btDevice.addressString];
		if (![self.devices containsObject:device]) {
			[self.devices addObject:device];
			[self postDeviceDidAppearNotification:device];
		}
    }
}

- (void)bluetoothDeviceDidDisconnectNotification:(IOBluetoothUserNotification *)note device:(IOBluetoothDevice *)btDevice
{
	DLog(DLogLevelInfo, @"bluetoothDeviceDidDisconnectNotification: %@", btDevice);
	
	if (!self.lastDisconnectedDeviceAddress || ![self.lastDisconnectedDeviceAddress isEqualToString:btDevice.addressString]) {
		self.lastDisconnectedDeviceAddress = btDevice.addressString;
		if ([self bluetoothDeviceSpeaksBladerunner:btDevice]) { // this is a sanity check since we shouldn't get the disconnect notification if the device wasn't a WC1 in the first place...
			BRDevice *removedDevice = nil;
			NSMutableIndexSet *removedIndex = [NSMutableIndexSet indexSet];
			for (NSUInteger i=0; i<[self.devices count]; i++) {
				BRDevice *d = self.devices[i];
				if ([d.bluetoothAddress isEqualToString:btDevice.addressString]) {
					removedDevice = self.devices[i];
					[removedIndex addIndex:i];
					[removedDevice closeConnection];
				}
			}
			if (removedDevice) {
				[self.devices removeObjectsAtIndexes:removedIndex];
				[self postDeviceDidDisappearNotification:removedDevice];
			}
			else {
				DLog(DLogLevelInfo, @"Device doesn't appear to match any of ours... Ignoring...");
			}
		}
	}
	else {
		DLog(DLogLevelWarn, @"Same device disconnected twice... Ignoring...");
	}
}

- (BOOL)bluetoothDeviceSpeaksBladerunner:(IOBluetoothDevice *)device
{
	NSString *uuidString = [PLTBladerunnerUUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
	NSData *uuidData = BRDeviceDataFromHexString(uuidString);
	IOBluetoothSDPUUID *uuid = [IOBluetoothSDPUUID uuidWithData:uuidData];
    for (IOBluetoothSDPServiceRecord *service in device.services) {
		if ([service hasServiceFromArray:@[uuid]]) {
			return YES;
		}
    }
    return NO;
}
#endif

#ifdef TARGET_IOS
- (void)accessoryDidConnectNotification:(NSNotification *)notification
{
	DLog(DLogLevelInfo, @"PLTDeviceWatcher: accessoryDidConnectNotification: %@", notification);
	
	EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
	if ([accessory.protocolStrings containsObject:PLTDeviceEAProtocolString]) {
		BRDevice *device = [BRDevice deviceWithAccessory:accessory];
		if (![self.devices containsObject:device]) {
			[self.devices addObject:device];
			[self postDeviceDidAppearNotification:device];
		}
	}
}

- (void)accessoryDidDisconnectNotification:(NSNotification *)notification
{
	DLog(DLogLevelInfo, @"PLTDeviceWatcher: accessoryDidDisconnectNotification:");
	
	EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
	if ([accessory.protocolStrings containsObject:PLTDeviceEAProtocolString]) {
		BRDevice *removedDevice = nil;
		NSMutableIndexSet *removedIndex = [NSMutableIndexSet indexSet];
		for (NSUInteger i=0; i<[self.devices count]; i++) {
			BRDevice *d = self.devices[i];
			if (d.accessory.connectionID == accessory.connectionID) {
				removedDevice = self.devices[i];
				[removedIndex addIndex:i];
				[removedDevice closeConnection];
			}
		}
		[self.devices removeObjectsAtIndexes:removedIndex];
		[self postDeviceDidDisappearNotification:removedDevice];
	}
}
#endif
		  
- (void)postDeviceDidAppearNotification:(BRDevice *)device
{
	DLog(DLogLevelInfo, @"postDeviceDidAppearNotification: %@", device);
	
	NSDictionary *userInfo = @{ BRDeviceNotificationKey : device };
	[[NSNotificationCenter defaultCenter] postNotificationName:BRDeviceDidAppearNotification object:nil userInfo:userInfo];
}

- (void)postDeviceDidDisappearNotification:(BRDevice *)device
{
	DLog(DLogLevelInfo, @"postDeviceDidDisappearNotification: %@", device);
	
	NSDictionary *userInfo = @{ BRDeviceNotificationKey : device };
	[[NSNotificationCenter defaultCenter] postNotificationName:BRDeviceDidDisappearNotification object:nil userInfo:userInfo];
}

@end
