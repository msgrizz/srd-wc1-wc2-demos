//
//  PLTDeviceWatcher.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//
//  Private singleton maintains a list of connectioned PLT bluetooth devices (in BT range), and devices with RFCOMM channels currently open.
//  

#import <Foundation/Foundation.h>


@interface PLTDeviceWatcher : NSObject

+ (PLTDeviceWatcher *)sharedWatcher;

@property(readonly)	NSMutableArray	*devices; // this should probably be an NSArray, but since this class is API internal.... this works.

@end
