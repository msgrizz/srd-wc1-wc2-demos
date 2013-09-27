//
//  PLTDeviceWatcher.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//
//  Private singleton maintains a list of connectioned accessories (in BT range), and accessories with data sessions currently open.
//  

#import <Foundation/Foundation.h>


extern NSString *const PLTDeviceProtocolString;


@interface PLTDeviceWatcher : NSObject

+ (PLTDeviceWatcher *)sharedWatcher;

@property(readonly)	NSMutableArray	*devices; // this should prpbably be an NSArray, but since this class is API internal.... this works.
//@property(readonly)	NSMutableArray	*connectedAccessories;

@end
