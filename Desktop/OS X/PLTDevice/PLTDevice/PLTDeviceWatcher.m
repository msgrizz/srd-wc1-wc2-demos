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
#import "BRDevice.h"
#import "BRDeviceWatcher.h"
#import "PLTDLog.h"


@interface PLTDeviceWatcher()

- (void)brDeviceDidAppearNotification:(NSNotification *)aNotification;
- (void)brDeviceDidDisappearNotification:(NSNotification *)aNotification;
- (void)postDeviceAvailableNotification:(PLTDevice *)device;

@property(nonatomic, strong)	NSMutableArray	*devices;

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
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(brDeviceDidAppearNotification:) name:BRDeviceDidAppearNotification object:nil];
		[nc addObserver:self selector:@selector(brDeviceDidDisappearNotification:) name:BRDeviceDidDisappearNotification object:nil];
		NSMutableArray *pltDevices = [NSMutableArray array];
		for (BRDevice *d in [BRDeviceWatcher sharedWatcher].devices) {
			[pltDevices addObject:[PLTDevice deviceWithBRDevice:d]];
		}
		self.devices = pltDevices;
    }
	
    return self;
}

- (void)brDeviceDidAppearNotification:(NSNotification *)aNotification
{
	BRDevice *brDevice = (BRDevice *)(aNotification.userInfo[BRDeviceNotificationKey]);
	DLog(DLogLevelInfo, @"brDeviceDidAppearNotification: %@", brDevice);
	
	PLTDevice *pltDevice = [PLTDevice deviceWithBRDevice:brDevice];
	
	if (![self.devices containsObject:pltDevice]) {
		[self.devices addObject:pltDevice];
		[self postDeviceAvailableNotification:pltDevice];
	}
}

- (void)brDeviceDidDisappearNotification:(NSNotification *)aNotification
{
	BRDevice *brDevice = (BRDevice *)(aNotification.userInfo[BRDeviceNotificationKey]);
	DLog(DLogLevelInfo, @"brDeviceDidDisappearNotification: %@", brDevice);
	
	PLTDevice *pltDevice = [PLTDevice deviceWithBRDevice:brDevice];
	
	BRDevice *removedDevice = nil;
	NSMutableIndexSet *removedIndex = [NSMutableIndexSet indexSet];
	for (NSUInteger i=0; i<[self.devices count]; i++) {
		PLTDevice *d = self.devices[i];
		if ([d isEqual:pltDevice]) {
			removedDevice = self.devices[i];
			[removedIndex addIndex:i];
			[removedDevice closeConnection];
		}
	}
	[self.devices removeObjectsAtIndexes:removedIndex];
}
		  
- (void)postDeviceAvailableNotification:(PLTDevice *)device
{
	DLog(DLogLevelInfo, @"postDeviceAvailableNotification: %@", device);
	
	NSDictionary *userInfo = @{ PLTDeviceNotificationKey : device };
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceAvailableNotification object:nil userInfo:userInfo];
}

@end
