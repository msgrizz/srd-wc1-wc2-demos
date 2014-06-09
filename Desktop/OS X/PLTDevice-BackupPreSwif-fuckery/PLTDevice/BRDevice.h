//
//  BRDevice.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BRMessage;
@class BREvent;
@class BRSettingResponse;
@class BRException;
@class BRMetadataMessage;
@class BRRemoteDevice;

#ifdef TARGET_IOS
@class EAAccessory;
#endif

@protocol BRDeviceDelegate;


#ifdef TARGET_IOS
typedef NS_ENUM(NSInteger, PLTDeviceErrorCode) {
	//BRDeviceErrorCodeUnknownError =                -1,
	BRDeviceErrorCodeFailedToCreateDataSession =   1,
	BRDeviceErrorCodeNoAccessoryAssociated =       2,
	BRDeviceErrorCodeConnectionAlreadyOpen =       3,
	//BRDeviceErrorInvalidArgument =                 4,
	//BRDeviceErrorInvalidService =                  5,
	//BRDeviceErrorUnsupportedService =              6,
	//BRDeviceErrorInvalidMode =                     7,
	//BRDeviceErrorUnsupportedMode =                 8,
	//BRDeviceErrorIncompatibleVersions =            9
};
#endif


@interface BRDevice : NSObject

#ifdef TARGET_OSX
+ (BRDevice *)deviceWithAddress:(NSString *)BTAddress;
#endif
#ifdef TARGET_IOS
+ (BRDevice *)deviceWithAccessory:(EAAccessory *)anAccessory;
#endif

- (void)openConnection;
- (void)closeConnection;
- (void)sendMessage:(BRMessage *)message;

#ifdef TARGET_OSX
@property(nonatomic,readonly)   NSString				*bluetoothAddress;
#endif
#ifdef TARGET_IOS
@property(nonatomic,readonly)	EAAccessory				*accessory;
#endif
@property(nonatomic,assign)     id <BRDeviceDelegate>   delegate;
@property(nonatomic,readonly)   BOOL                    isConnected;
@property(nonatomic,readonly)	NSDictionary			*remoteDevices;
@property(nonatomic,readonly)	NSArray					*commands;
@property(nonatomic,readonly)	NSArray					*settings;
@property(nonatomic,readonly)	NSArray					*events;

@end


@protocol BRDeviceDelegate <NSObject>

- (void)BRDeviceDidConnect:(BRDevice *)device;
- (void)BRDeviceDidDisconnect:(BRDevice *)device;
- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError;
- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event;
- (void)BRDevice:(BRDevice *)device didReceiveSettingResponse:(BRSettingResponse *)settingResponse;
- (void)BRDevice:(BRDevice *)device didRaiseException:(BRException *)exception;
- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data;
- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data;
- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice;

@end

