//
//  BRDevice_Private.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDevice.h"


typedef enum {
    BRDeviceStateDisconnected,
	
#ifdef TARGET_OSX
    BRDeviceStateOpeningRFCOMMChannel,
#endif
#ifdef TARGET_IOS
	BRDeviceStateOpeningEASession,
#endif
    BRDeviceStateHostVersionNegotiating,
	BRDeviceStateConnected
} BRDeviceState;


@interface BRDevice ()

#ifdef TARGET_OSX
@property(nonatomic,strong,readwrite)   NSString			*bluetoothAddress;
#endif
#ifdef TARGET_IOS
@property(nonatomic,strong,readwrite)	EAAccessory			*accessory;
#endif

@property(nonatomic,assign,readwrite)   BOOL				isConnected;
@property(nonatomic,assign,readwrite)	BRDeviceState		state;
@property(nonatomic,strong,readwrite)	NSArray				*commands;
@property(nonatomic,strong,readwrite)	NSArray				*settings;
@property(nonatomic,strong,readwrite)	NSArray				*events;

@end