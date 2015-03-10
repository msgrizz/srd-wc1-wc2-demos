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
@class BRSettingResult;
@class BRException;
@class BRMetadataMessage;
@class BRRemoteDevice;
@class BRIncomingMessage;

#ifdef TARGET_IOS
@class EAAccessory;
#endif

@protocol BRDeviceDelegate;


extern NSString *const BRDeviceDidAppearNotification;
extern NSString *const BRDeviceDidDisappearNotification;
extern NSString *const BRDeviceNotificationKey;


#ifdef TARGET_IOS
typedef NS_ENUM(NSInteger, BRDeviceError) {
	BRDeviceErrorFailedToCreateDataSession =		1,
	BRDeviceErrorNoAccessoryAssociated =			2,
	BRDeviceErrorConnectionAlreadyOpen =			3,
};
#endif


@interface BRDevice : NSObject

+ (NSArray *)availableDevices;

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

@required
- (void)BRDeviceDidConnect:(BRDevice *)device;
- (void)BRDeviceDidDisconnect:(BRDevice *)device;
- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError;
- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event;
- (void)BRDevice:(BRDevice *)device didReceiveSettingResult:(BRSettingResult *)settingResult;
- (void)BRDevice:(BRDevice *)device didRaiseSettingException:(BRException *)exception;
- (void)BRDevice:(BRDevice *)device didRaiseCommandException:(BRException *)exception;
- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice;

@optional
- (void)BRDevice:(BRDevice *)device didReceiveUnknownMessage:(BRIncomingMessage *)unknownMessage;
- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data;
- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data;

@end
