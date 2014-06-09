//
//  BRDevice.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef TARGET_OSX
#import <BRDevice/BRMessage.h>
#import <BRDevice/BRIncomingMessage.h>
#import <BRDevice/BROutgoingMessage.h>
#import <BRDevice/BRHostVersionNegotiateMessage.h>
#import <BRDevice/BRDeviceProtocolVersionMessage.h>
#import <BRDevice/BRMetadataMessage.h>
#import <BRDevice/BRCloseSessionMessage.h>
#import <BRDevice/BRRawMessage.h>
#import <BRDevice/BRCommand.h>
#import <BRDevice/BRSubscribeToSignalStrengthCommand.h>
#import <BRDevice/BRSubscribeToServiceCommand.h>
#import <BRDevice/BRCalibratePedometerServiceCommand.h>
#import <BRDevice/BRPerformApplicationActionCommand.h>
#import <BRDevice/BRSettingRequest.h>
#import <BRDevice/BRDeviceInfoSettingRequest.h>
#import <BRDevice/BRGenesGUIDSettingRequest.h>
#import <BRDevice/BRProductNameSettingRequest.h>
#import <BRDevice/BRServiceCalibrationSettingRequest.h>
#import <BRDevice/BRServiceDataSettingRequest.h>
#import <BRDevice/BRSignalStrengthSettingRequest.h>
#import <BRDevice/BRWearingStateSettingRequest.h>
#import <BRDevice/BRSettingResponse.h>
#import <BRDevice/BRDeviceInfoSettingResponse.h>
#import <BRDevice/BRFreeFallSettingResponse.h>
#import <BRDevice/BRGenesGUIDSettingResponse.h>
#import <BRDevice/BRGyroscopeCalStatusSettingResponse.h>
#import <BRDevice/BRMagnetometerCalStatusSettingResponse.h>
#import <BRDevice/BROrientationTrackingSettingResponse.h>
#import <BRDevice/BRPedometerSettingResponse.h>
#import <BRDevice/BRProductNameSettingResponse.h>
#import <BRDevice/BRSignalStrengthSettingResponse.h>
#import <BRDevice/BRTapsSettingResponse.h>
#import <BRDevice/BRWearingStateSettingResponse.h>
#import <BRDevice/BREvent.h>
#import <BRDevice/BRApplicationActionResultEvent.h>
#import <BRDevice/BRDeviceConnectedEvent.h>
#import <BRDevice/BRDeviceDisconnectedEvent.h>
#import <BRDevice/BRFreeFallEvent.h>
#import <BRDevice/BRGyroscopeCalStatusEvent.h>
#import <BRDevice/BRMagnetometerCalStatusEvent.h>
#import <BRDevice/BROrientationTrackingEvent.h>
#import <BRDevice/BRPedometerEvent.h>
#import <BRDevice/BRServiceSubscriptionChangedEvent.h>
#import <BRDevice/BRSignalStrengthEvent.h>
#import <BRDevice/BRTapsEvent.h>
#import <BRDevice/BRWearingStateEvent.h>
#import <BRDevice/BRException.h>
#import <BRDevice/BRIllegalValueException.h>
#import <BRDevice/BRDeviceNotReadyException.h>
#endif
#ifdef TARGET_IOS
//#import "BRRemoteDevice.h"
#import "BRMessage.h"
#import "BRIncomingMessage.h"
#import "BROutgoingMessage.h"
#import "BRHostVersionNegotiateMessage.h"
#import "BRDeviceProtocolVersionMessage.h"
#import "BRMetadataMessage.h"
#import "BRCloseSessionMessage.h"
#import "BRRawMessage.h"
#import "BRCommand.h"
#import "BRSubscribeToSignalStrengthCommand.h"
#import "BRSubscribeToServiceCommand.h"
#import "BRCalibratePedometerServiceCommand.h"
#import "BRPerformApplicationActionCommand.h"
#import "BRSettingRequest.h"
#import "BRDeviceInfoSettingRequest.h"
#import "BRGenesGUIDSettingRequest.h"
#import "BRProductNameSettingRequest.h"
#import "BRServiceCalibrationSettingRequest.h"
#import "BRServiceDataSettingRequest.h"
#import "BRSignalStrengthSettingRequest.h"
#import "BRWearingStateSettingRequest.h"
#import "BRSettingResponse.h"
#import "BRDeviceInfoSettingResponse.h"
#import "BRFreeFallSettingResponse.h"
#import "BRGenesGUIDSettingResponse.h"
#import "BRGyroscopeCalStatusSettingResponse.h"
#import "BRMagnetometerCalStatusSettingResponse.h"
#import "BROrientationTrackingSettingResponse.h"
#import "BRPedometerSettingResponse.h"
#import "BRProductNameSettingResponse.h"
#import "BRSignalStrengthSettingResponse.h"
#import "BRTapsSettingResponse.h"
#import "BRWearingStateSettingResponse.h"
#import "BREvent.h"
#import "BRApplicationActionResultEvent.h"
#import "BRDeviceConnectedEvent.h"
#import "BRDeviceDisconnectedEvent.h"
#import "BRFreeFallEvent.h"
#import "BRGyroscopeCalStatusEvent.h"
#import "BRMagnetometerCalStatusEvent.h"
#import "BROrientationTrackingEvent.h"
#import "BRPedometerEvent.h"
#import "BRServiceSubscriptionChangedEvent.h"
#import "BRSignalStrengthEvent.h"
#import "BRTapsEvent.h"
#import "BRWearingStateEvent.h"
#import "BRException.h"
#import "BRIllegalValueException.h"
#import "BRDeviceNotReadyException.h"
#endif

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

