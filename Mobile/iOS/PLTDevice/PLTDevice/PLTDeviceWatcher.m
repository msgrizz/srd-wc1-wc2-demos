//
//  PLTDeviceWatcher.m
//  PLTDevice
//
//  Created by Davis, Morgan on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTDeviceWatcher.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "PLTDevice.h"
#import "PLTDevice_Internal.h"


NSString *const PLTDeviceProtocolString =					@"com.plt.protocol1";


@interface PLTDeviceWatcher()

- (void)accessoryDidConnectNotification:(NSNotification *)notification;
- (void)accessoryDidDisconnectNotification:(NSNotification *)notification;
- (void)postNewDeviceNotification:(PLTDevice *)device;

@property(nonatomic, strong)	NSMutableArray	*devices;
//@property(nonatomic, strong)	NSMutableArray	*connectedAccessories;

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
		
		//self.connectedAccessories = [NSMutableArray array];
		
		self.devices = [NSMutableArray array];
		NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
		NSLog(@"Connected accessories: %@",accessories);
		for (EAAccessory *a in accessories) {
			PLTDevice *device = [[PLTDevice alloc] initWithAccessory:a];
			[self.devices addObject:device];
		}
	
		[[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnectNotification:) name:EAAccessoryDidConnectNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnectNotification:) name:EAAccessoryDidDisconnectNotification object:nil];
    }
	
    return self;
}

- (void)accessoryDidConnectNotification:(NSNotification *)notification
{
	NSLog(@"PLTDeviceWatcher: accessoryDidConnectNotification: %@", notification);
	
	EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
	if ([accessory.protocolStrings containsObject:PLTDeviceProtocolString]) {
		PLTDevice *device = [[PLTDevice alloc] initWithAccessory:accessory];
		if (![self.devices containsObject:device]) {
			[self.devices addObject:device];
			[self postNewDeviceNotification:device];
		}
	}
}

- (void)accessoryDidDisconnectNotification:(NSNotification *)notification
{
	NSLog(@"PLTDeviceWatcher: accessoryDidDisconnectNotification: %@", notification);
	
	EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
	if ([accessory.protocolStrings containsObject:PLTDeviceProtocolString]) {
		//	PLTDevice *device = [[PLTDevice alloc] initWithAccessory:accessory];
		NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
		for (NSUInteger i=0; i<[self.devices count]; i++) {
			PLTDevice *d = self.devices[i];
			if (d.accessory.connectionID == accessory.connectionID) {
				[toRemove addIndex:i];
				[d closeConnection];
			}
		}
		[self.devices removeObjectsAtIndexes:toRemove];
	}
}
		  
- (void)postNewDeviceNotification:(PLTDevice *)device
{
	NSLog(@"postNewAccessoryNotification: %@", device);
	
	NSDictionary *userInfo = @{ PLTDeviceNewDeviceNotificationKey : device };
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceNewDeviceAvailableNotification object:nil userInfo:userInfo];
}

@end
