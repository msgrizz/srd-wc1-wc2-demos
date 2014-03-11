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
@protocol BRDeviceDelegate;


@interface BRDevice : NSObject

+ (BRDevice *)deviceWithAddress:(NSString *)BTAddress;
- (void)openConnection;
- (void)sendMessage:(BRMessage *)message;

@property(nonatomic,assign)     id <BRDeviceDelegate>   delegate;
@property(nonatomic,readonly)   NSString                *BTAddress;
@property(nonatomic,readonly)   BOOL                    isConnected;

@end


@protocol BRDeviceDelegate <NSObject>

- (void)BRDeviceDidConnectToHTDevice:(BRDevice *)device;
- (void)BRDeviceDidDisconnectFromHTDevice:(BRDevice *)device;
- (void)BRDevice:(BRDevice *)device didFailConnectToHTDeviceWithError:(int)ioBTError;
- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event;
- (void)BRDevice:(BRDevice *)device didReceiveSettingResponse:(BRSettingResponse *)settingResponse;
- (void)BRDevice:(BRDevice *)device didRaiseException:(BRException *)exception;

@end

