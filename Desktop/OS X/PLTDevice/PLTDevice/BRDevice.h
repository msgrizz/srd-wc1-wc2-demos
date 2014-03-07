//
//  BRDevice.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BRMessage;
@class BREvent;
@protocol BRDeviceDelegate;


typedef enum {
    BRServiceIDOrientationTracking = 0,
    BRServiceIDPedometer = 2,
    BRServiceIDFreeFall = 3,
    BRServiceIDTaps = 4,
    BRServiceIDMagCal = 5,
    BRServiceIDGyroCal = 6,
    BRServiceIDTemp = 11
} BRServiceID;

typedef enum {
    BRServiceSubscriptionModeOff = 0,
    BRServiceSubscriptionModeOnChange = 1,
    BRServiceSubscriptionModePeriodic = 2
} BRServiceSubscriptionMode;


@interface BRDevice : NSObject

+ (BRDevice *)controllerWithDeviceAddress:(NSString *)BTAddress;
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

@end

