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
@protocol BRDeviceDelegate;


@interface BRDevice : NSObject

+ (BRDevice *)deviceWithAddress:(NSString *)BTAddress;
- (void)openConnection;
- (void)closeConnection;
- (void)sendMessage:(BRMessage *)message;

@property(nonatomic,assign)     id <BRDeviceDelegate>   delegate;
@property(nonatomic,readonly)   NSString                *bluetoothAddress;
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

