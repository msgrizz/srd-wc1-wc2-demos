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
@class BRMetadata;
@protocol BRDeviceDelegate;


@interface BRDevice : NSObject

+ (BRDevice *)deviceWithAddress:(NSString *)BTAddress;
- (void)openConnection;
- (void)closeConnection;
- (void)sendMessage:(BRMessage *)message;

@property(nonatomic,assign)     id <BRDeviceDelegate>   delegate;
@property(nonatomic,readonly)   NSString                *BTAddress;
@property(nonatomic,readonly)   BOOL                    isConnected;



//@property(nonatomic,assign)   uint32_t                address;
//@property(nonatomic,strong)   NSArray                 *commands;
//@property(nonatomic,strong)   NSArray                 *settings;
//@property(nonatomic,strong)   NSArray                 *events;


@end


@protocol BRDeviceDelegate <NSObject>

- (void)BRDeviceDidConnectToHTDevice:(BRDevice *)device;
- (void)BRDeviceDidDisconnectFromHTDevice:(BRDevice *)device;
- (void)BRDevice:(BRDevice *)device didFailConnectToHTDeviceWithError:(int)ioBTError;
- (void)BRDevice:(BRDevice *)device didReceiveMetadata:(BRMetadata *)metadata;
- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event;
- (void)BRDevice:(BRDevice *)device didReceiveSettingResponse:(BRSettingResponse *)settingResponse;
- (void)BRDevice:(BRDevice *)device didRaiseException:(BRException *)exception;
- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data;
- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data;



//- (void)BRDevice:(BRDevice *)device didDiscoverAdjacentDevice:(BRDevice *)newDevice;

@end

