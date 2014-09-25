//
//  PLTDevice.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "Configuration.h"
#import "PLTDLog.h"

#ifdef TARGET_OSX
#import <CoreServices/CoreServices.h>
#endif
#ifdef TARGET_IOS
#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>
#endif

#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
#import "PLTDeviceWatcher.h"
#import "PLTInfo_Internal.h"
#import "PLTWearingStateInfo_Internal.h"
#import "PLTProximityInfo_Internal.h"
#import "PLTOrientationTrackingInfo_Internal.h"
#import "PLTTapsInfo_Internal.h"
#import "PLTPedometerInfo_Internal.h"
#import "PLTFreeFallInfo_Internal.h"
#import "PLTPedometerCalibration.h"
#import "PLTMagnetometerCalibrationInfo_Internal.h"
#import "PLTGyroscopeCalibrationInfo_Internal.h"

#import "BRDevice.h"
#import "BRRemoteDevice.h"
#import "BRSubscribeToServiceCommand.h"
#import "BRSubscribeToSignalStrengthCommand.h"
#import "BROrientationTrackingEvent.h"
#import "BRTapsEvent.h"
#import "BRFreeFallEvent.h"
#import "BRPedometerEvent.h"
#import "BRMagnetometerCalStatusEvent.h"
#import "BRGyroscopeCalStatusEvent.h"
#import "BRWearingStateEvent.h"
#import "BRSignalStrengthEvent.h"
#import "BRSettingResponse.h"
#import "BRServiceDataSettingRequest.h"
#import "BRDeviceInfoSettingRequest.h"
#import "BRDeviceInfoSettingResponse.h"
#import "BRWearingStateSettingRequest.h"
#import "BRWearingStateSettingResponse.h"
#import "BRSignalStrengthSettingRequest.h"
#import "BRSignalStrengthSettingResponse.h"
#import "BROrientationTrackingSettingResponse.h"
#import "BRTapsSettingResponse.h"
#import "BRPedometerSettingResponse.h"
#import "BRFreeFallSettingResponse.h"
#import "BRMagnetometerCalStatusSettingResponse.h"
#import "BRGyroscopeCalStatusSettingResponse.h"
#import "BRGenesGUIDSettingRequest.h"
#import "BRGenesGUIDSettingResponse.h"
#import "BRProductNameSettingRequest.h"
#import "BRProductNameSettingResponse.h"
#import "BRException.h"

#import "NSData+HexStrings.h"
#import "NSArray+PrettyPrint.h"

#warning BANGLE
#import "PLTDevice_Bangle.h"
#import "BRSubscribedServiceDataEvent.h"
#import "PLTSkinTemperatureInfo.h"
#import "PLTAmbientHumidityInfo.h"
#import "PLTAmbientPressureInfo.h"


NSString *const PLTDeviceAvailableNotification =							@"PLTDeviceAvailableNotification";
NSString *const PLTDeviceDidOpenConnectionNotification =					@"PLTDeviceDidOpenConnectionNotification";
NSString *const PLTDeviceDidFailOpenConnectionNotification =				@"PLTDeviceDidFailOpenConnectionNotification";
NSString *const PLTDeviceDidCloseConnectionNotification =					@"PLTDeviceDidCloseConnectionNotification";
NSString *const PLTDeviceWillSendDataNotification =							@"PLTDeviceWillSendDataNotification";
NSString *const PLTDeviceDidReceiveDataNotification =						@"PLTDeviceDidReceiveDataNotification";


NSString *const PLTDeviceNotificationKey =									@"PLTDeviceNotificationKey";
NSString *const PLTDeviceConnectionErrorNotificationKey =					@"PLTDeviceConnectionErrorNotificationKey";
NSString *const PLTDeviceDataNotificationKey =								@"PLTDeviceDataNotificationKey";

NSString *const PLTDeviceErrorDomain =										@"com.plantronics.PLTDevice";


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


PLTQuaternion PLTQuaternionFromBRQuaternion(BRQuaternion brQuaternion)
{
	return (PLTQuaternion){ brQuaternion.w, brQuaternion.x, brQuaternion.y, brQuaternion.z };
}


@interface PLTSubscription ()

+ (PLTSubscription *)subscriptionWithService:(PLTService)service mode:(PLTSubscriptionMode)mode period:(uint16_t)period subscriber:(id<PLTDeviceSubscriber>)subscriber;
+ (PLTSubscription *)subscriptionWithService:(PLTService)service mode:(PLTSubscriptionMode)mode period:(uint16_t)period subscribers:(NSArray *)subscribers;
- (void)addSubscriber:(id<PLTDeviceSubscriber>)subscriber;
- (void)removeSubscriber:(id<PLTDeviceSubscriber>)subscriber;
- (NSString *)privateDescription;

@property(nonatomic,assign,readwrite)	PLTService							service;
@property(nonatomic,assign,readwrite)	PLTSubscriptionMode					mode;
@property(nonatomic,assign,readwrite)	uint16_t							period;
@property(nonatomic,strong,readwrite)	NSMutableArray						*subscribers;

@end


@interface PLTDevice() <BRDeviceDelegate>

- (void)didOpenBRConnection;
- (void)didCloseConnection:(BOOL)notify;
- (void)didGetProductName:(BRProductNameSettingResponse *)response;
- (void)didGetGUID:(BRGenesGUIDSettingResponse *)response;
- (void)didGetDeviceInfo:(BRDeviceInfoSettingResponse *)response;
- (void)didFinishHandshake;
//- (void)didTimeoutOpenConnection:(NSTimer *)aTimer;
- (void)configureSignalStrengthEventsEnabled:(BOOL)enabled connectionID:(uint8_t)connectionID;
- (void)queryWearingState;
- (void)querySignalStrength:(uint8_t)connectionID;
- (void)startWearingStateTimer:(uint16_t)period;
- (void)startSignalStrengthTimer:(uint16_t)period;
- (void)wearingStateTimer:(NSTimer *)aTimer;
- (void)signalStrengthTimer:(NSTimer *)aTimer;
- (NSError *)checkConnectionOpenError;

//@property(nonatomic,strong,readwrite)	BRDevice							*brDevice;
@property(nonatomic,strong)				BRDevice							*brSensorsDevice;

@property(nonatomic,readwrite)			BOOL								isConnectionOpen;

@property(nonatomic,strong)				NSMutableDictionary					*subscriptions;
@property(nonatomic,strong)				NSMutableDictionary					*querySubscribers;
@property(nonatomic,strong)				NSMutableDictionary					*cachedInfo;

//#ifdef TARGET_OSX
@property(nonatomic,strong,readwrite)	NSString							*address;
//#endif
@property(nonatomic,strong,readwrite)	NSString							*model;
@property(nonatomic,strong,readwrite)	NSString							*name;
@property(nonatomic,strong,readwrite)	NSString							*serialNumber;
@property(nonatomic,strong,readwrite)	NSString							*hardwareVersion;
@property(nonatomic,strong,readwrite)	NSString							*firmwareVersion;

@property(nonatomic,strong,readwrite)	NSArray								*supportedServices;

@property(nonatomic,assign)				int8_t								remotePort;
@property(nonatomic,strong)				NSTimer								*wearingStateTimer;
@property(nonatomic,strong)				NSTimer								*signalStrengthTimer;

@property(nonatomic,assign)				BOOL								waitingForWearingStatePrimer;
@property(nonatomic,assign)				BOOL								waitingForRemoteSignalStrengthEvent;
@property(nonatomic,assign)				BOOL								waitingForLocalSignalStrengthEvent;
@property(nonatomic,strong)				BRSignalStrengthEvent				*localQuerySignalStrengthEvent;
@property(nonatomic,strong)				BRSignalStrengthEvent				*remoteQuerySignalStrengthEvent;
@property(nonatomic,assign)				BOOL								waitingForRemoteSignalStrengthSettingResponse;
@property(nonatomic,assign)				BOOL								waitingForLocalSignalStrengthSettingResponse;
@property(nonatomic,strong)				BRSignalStrengthSettingResponse		*localQuerySignalStrengthResponse;
@property(nonatomic,strong)				BRSignalStrengthSettingResponse		*remoteQuerySignalStrengthResponse;

#warning reset these on open/close/whatever
@property(nonatomic,strong)				PLTOrientationTrackingCalibration	*orientationTrackingCalibration;
@property(nonatomic,assign)				NSUInteger							pedometerOffset;
@property(nonatomic,assign)				BOOL								queryingOrientationTrackingForCalibration;

@end


@implementation PLTDevice

#pragma mark - Public

+ (NSArray *)availableDevices
{
#ifdef TARGET_OSX
	SInt32 major, minor, bugfix;
	Gestalt(gestaltSystemVersionMajor, &major);
	Gestalt(gestaltSystemVersionMinor, &minor);
	Gestalt(gestaltSystemVersionBugFix, &bugfix);
	
	if (minor < 9) {
		[NSException raise:@"Incompatible OS version"
					format:@"PLTDevice is not compatible with this version of OS X (%d.%d.%d). Please install OS 10.9 or later.", major, minor, bugfix];
	}
#endif
#ifdef TARGET_IOS
	if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
		[NSException raise:@"Incompatible OS version"
					format:@"PLTDevice is not compatible with this version of iOS (%@). Please install iOS 7.0 or later.", [[UIDevice currentDevice] systemVersion]];
	}
#endif
	
	if (![[NSData data] respondsToSelector:@selector(hexStringWithSpaceEvery:)]) {
		[NSException raise:@"PLT categories not found"
					format:@"PLT categories don't appear to be loaded. Make sure to link with the -all_load and -ObjC linker flags."];
	}
	
	[PLTDLogger sharedLogger];
	
//	static BOOL initdLog = NO;
//	if (!initdLog) {
//		_pltDLogLevel = DLogLevelError;
//		initdLog = YES;
//	}
	
	return [[PLTDeviceWatcher sharedWatcher] devices];
}

- (void)openConnection:(NSError **)error
{
	DLog(DLogLevelDebug, @"openConnection:");
	
	if (!self.isConnectionOpen) {
		
#ifdef TARGET_OSX
		self.brDevice = [BRDevice deviceWithAddress:self.address];
#endif
#ifdef TARGET_IOS
		self.brDevice = [BRDevice deviceWithAccessory:self.accessory];
#endif
        self.brDevice.delegate = self;
		self.remotePort = -1;
		
#ifdef TARGET_OSX
		DLog(DLogLevelInfo, @"Connecting to device at %@...", self.brDevice.bluetoothAddress);
#endif
#ifdef TARGET_IOS
		DLog(DLogLevelInfo, @"Connecting to accessory %@...", self.accessory);
#endif
        [self.brDevice openConnection]; // wait for open callback
	}
	else {
		DLog(DLogLevelWarn, @"Connection already open.");
		*error = [NSError errorWithDomain:PLTDeviceErrorDomain
									 code:PLTDeviceErrorConnectionAlreadyOpen
								 userInfo:@{NSLocalizedDescriptionKey : @"Connection already open."}];
	}
}

- (void)closeConnection
{
	[self.brDevice closeConnection];
}

- (void)setConfiguration:(PLTConfiguration *)configuration forService:(PLTService)service error:(NSError **)error;
{
	DLog(DLogLevelInfo, @"setConfiguration: %@, forService: %u", configuration, service);
	
	NSError *connectionNotOpenError = [self checkConnectionOpenError];
	if (connectionNotOpenError) {
		*error = connectionNotOpenError;
		return;
	}
	
	*error = [NSError errorWithDomain:PLTDeviceErrorDomain
								 code:PLTDeviceErrorInvalidService
							 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
}

- (PLTConfiguration *)configurationForService:(PLTService)service error:(NSError **)error;
{
	NSError *connectionNotOpenError = [self checkConnectionOpenError];
	if (connectionNotOpenError) {
		*error = connectionNotOpenError;
		return nil;
	}
	
	*error = [NSError errorWithDomain:PLTDeviceErrorDomain
								 code:PLTDeviceErrorInvalidService
							 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
	return nil;
}

- (void)setCalibration:(PLTCalibration *)cal forService:(PLTService)service error:(NSError **)error
{
	DLog(DLogLevelInfo, @"setCalibration: %@, forService: %u", cal, service);
	
	NSError *connectionNotOpenError = [self checkConnectionOpenError];
	if (connectionNotOpenError) {
		*error = connectionNotOpenError;
		return;
	}
	
	switch (service) {
		case PLTServiceOrientationTracking: {
			PLTOrientationTrackingCalibration *theCal = nil;
			
			if (!cal) {
				PLTOrientationTrackingInfo *orientationInfo = (PLTOrientationTrackingInfo *)self.cachedInfo[@(service)];
				if (orientationInfo) {
					theCal = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:orientationInfo.uncalibratedQuaternion];
				}
			}
			if (theCal) {
				_orientationTrackingCalibration = theCal;
			}
			else {
				// no saved orientation info to use for cal. query info and use that.
				[self queryOrientationTrackingForCal];
			}
			break; }
		case PLTServicePedometer: {
			PLTPedometerCalibration *pedCal = (PLTPedometerCalibration *)cal;
			if (!pedCal || pedCal.reset) {
				PLTPedometerInfo *pedInfo = (PLTPedometerInfo *)self.cachedInfo[@(service)];
				if (pedInfo) {
					NSInteger steps = pedInfo.steps;
					if (steps > 0) {
						self.pedometerOffset += steps;
					}
				}
			}
			break; }
		default:
			*error = [NSError errorWithDomain:PLTDeviceErrorDomain
										 code:PLTDeviceErrorInvalidService
									 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
			break;
	}
}

- (PLTCalibration *)calibrationForService:(PLTService)theService error:(NSError **)error
{
	NSError *connectionNotOpenError = [self checkConnectionOpenError];
	if (connectionNotOpenError) {
		*error = connectionNotOpenError;
		return nil;
	}
	
	if (theService == PLTServiceOrientationTracking) {
		return (PLTCalibration *)self.orientationTrackingCalibration;
	}
	else {
		*error = [NSError errorWithDomain:PLTDeviceErrorDomain
									 code:PLTDeviceErrorInvalidService
								 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
	}
	return nil;
}

- (void)subscribe:(id <PLTDeviceSubscriber>)subscriber toService:(PLTService)service withMode:(PLTSubscriptionMode)mode andPeriod:(NSUInteger)period error:(NSError **)error
{
	DLog(DLogLevelInfo, @"subscribe: %@ toService: 0x%04X withMode: %lu minPeriod: %lu", subscriber, service, mode, (unsigned long)period);
	
	NSError *connectionNotOpenError = [self checkConnectionOpenError];
	if (connectionNotOpenError) {
		*error = connectionNotOpenError;
		return;
	}
	
	if (subscriber != nil) {
#warning check supportedServices
		switch (service) {
			case PLTServiceWearingState:
			case PLTServiceProximity:
			case PLTServiceOrientationTracking:
			case PLTServicePedometer:
			case PLTServiceFreeFall:
			case PLTServiceTaps:
			case PLTServiceMagnetometerCalibrationStatus:
			case PLTServiceGyroscopeCalibrationStatus:
#ifdef BANGLE
			case PLTServiceAmbientHumidity:
			case PLTServiceAmbientLight:
				// optical proximity
			case PLTServiceAmbientTemperature:
			case PLTServiceSkinTemperature:
			case PLTServiceSkinConductivity:
			case PLTServiceAmbientPressure:
			case PLTServiceHeartRate:
#endif
				// cool.
				break;
			default:
				DLog(DLogLevelError, @"Invalid service: %lu", service);
				*error = [NSError errorWithDomain:PLTDeviceErrorDomain
											 code:PLTDeviceErrorInvalidService
										 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
				return;
		}
		
		if (mode!=PLTSubscriptionModeOnChange && mode!=PLTSubscriptionModePeriodic) {
			DLog(DLogLevelError, @"Invalid subscription mode: %lu", mode);
			*error = [NSError errorWithDomain:PLTDeviceErrorDomain
										 code:PLTDeviceErrorInvalidMode
									 userInfo:@{NSLocalizedDescriptionKey : @"Invalid subscription mode."}];
			return;
		}

		// get the subscription with the matching serviceID.
		// 1. if doesnt exist, create it. add listener. add subscription. notify subscribers. execute BR command.
		// 2. if exists and the mode is different, change to new mode. remove and re-add listener. update subscription. notify all listeners. execute BR command.
		// 3. if exists and mode is onchange for both, remove and re-add listener. update subscription. dont notify subscribers. dont execute BR command.
		// 4. if exists and mode is periodic for both and both periods ARE the same, remove and re-add listener. update subscription. dont notify subscribers. dont execute BR command.
		// UPDATE: how about do nothing?
		// 5. if exists and mode is periodic for both and both periods are NOT the same, remove and re-add listener. update subscription. notify all subscribers. execute BR command.
		
		NSMutableArray *subscribersToNotify = [NSMutableArray array];
		PLTSubscription *oldSubscription;
		PLTSubscription *sub = self.subscriptions[@(service)];
		NSMutableArray *subscribers = [NSMutableArray arrayWithObject:subscriber];
		[subscribers addObjectsFromArray:sub.subscribers];
		PLTSubscription *newSubscription = [PLTSubscription subscriptionWithService:service mode:mode period:period subscribers:subscribers];
		BOOL case1 = false;
		
		// 1.
		if (!sub) {
			case1 = true;
			self.subscriptions[@(service)] = newSubscription;
			[subscribersToNotify addObject:subscriber];
			oldSubscription = nil;
		}
		else {
			oldSubscription = nil;
			
			// 2.
			if (mode != sub.mode) {
				[subscribersToNotify addObjectsFromArray:sub.subscribers];
				[sub addSubscriber:subscriber]; // removes and re-adds
				self.subscriptions[@(service)] = newSubscription;
			}
			// 3.
			else if (mode==PLTSubscriptionModeOnChange && sub.mode==PLTSubscriptionModeOnChange) {
				[sub addSubscriber:subscriber]; // removes and re-adds
				self.subscriptions[@(service)] = newSubscription;
			}
			else if (mode==PLTSubscriptionModePeriodic && sub.mode==PLTSubscriptionModePeriodic) {
				// 4.
				if (period==sub.period) {
					[sub addSubscriber:subscriber]; // removes and re-adds
					self.subscriptions[@(service)] = newSubscription;
				}
				// 5.
				else {
					[sub addSubscriber:subscriber]; // removes and re-adds
					self.subscriptions[@(service)] = newSubscription;
					[subscribersToNotify addObjectsFromArray:sub.subscribers];
				}
			}
		}
		
		if ([subscribersToNotify count]) {
			
			for (id<PLTDeviceSubscriber> s in subscribersToNotify) {
				[s PLTDevice:self didChangeSubscription:oldSubscription toSubscription:newSubscription];
			}
			
			if (service!=PLTServiceWearingState && service!=PLTServiceProximity) {
				
				BRSubscribeToServiceCommand *command = [BRSubscribeToServiceCommand commandWithServiceID:newSubscription.service
																									mode:newSubscription.mode
																								  period:newSubscription.period];
				
				[self.brSensorsDevice sendMessage:command];
			}
		}
		
		// now for wearing state and proximity. we'll reference the "case" from above.
		
		if (service == PLTServiceWearingState) {
			BOOL periodic = newSubscription.mode == PLTSubscriptionModePeriodic;
			
			if (periodic) {
				[self startWearingStateTimer:period];
			}
			else if (self.wearingStateTimer) {
				[self.wearingStateTimer invalidate];
			}
		}
		else if (service == PLTServiceProximity) {
			BOOL periodic = newSubscription.mode == PLTSubscriptionModePeriodic;
			
			if (case1) {
				[self configureSignalStrengthEventsEnabled:YES connectionID:0];
				if (self.remotePort > 0) {
					[self configureSignalStrengthEventsEnabled:YES connectionID:self.remotePort];
				}
			}
			
			if (periodic) {
				[self startSignalStrengthTimer:period];
			}
			else if (self.signalStrengthTimer) {
				[self.signalStrengthTimer invalidate];
			}
		}
	}
	else {
		DLog(DLogLevelError, @"Subscriber is nil!");
		*error = [NSError errorWithDomain:PLTDeviceErrorDomain
									 code:PLTDeviceErrorInvalidArgument
								 userInfo:@{NSLocalizedDescriptionKey : @"Subscriber is nil."}];
	}
}

- (void)unsubscribe:(id <PLTDeviceSubscriber>)subscriber fromService:(PLTService)service
{
	DLog(DLogLevelDebug, @"unsubscribe: %@ fromService: %lu", subscriber, service);
	
	if (self.isConnectionOpen) {
		if (subscriber) {
			switch (service) {
				case PLTServiceWearingState:
				case PLTServiceProximity:
				case PLTServiceOrientationTracking:
				case PLTServicePedometer:
				case PLTServiceFreeFall:
				case PLTServiceTaps:
				case PLTServiceMagnetometerCalibrationStatus:
				case PLTServiceGyroscopeCalibrationStatus:
					// cool.
					break;
				default:
					DLog(DLogLevelWarn, @"Invalid service: %lu", service);
					// who cares, you're unsubscribed!
					return;
			}
			
			NSMutableArray *subscribersToNotify = [NSMutableArray array];
			PLTSubscription *oldSubscription;
			BOOL execCommand = NO;
			
			PLTSubscription *sub = self.subscriptions[@(service)];
			// 1.
			if (!sub) {
				// done!
			}
			else {
				if (![sub.subscribers containsObject:subscriber]) {
					// done!
				}
				else {
					oldSubscription = sub;
					[subscribersToNotify addObject:subscriber];
					
					if ([sub.subscribers count] > 1) {
						[sub removeSubscriber:subscriber];
					}
					else {
						[self.subscriptions removeObjectForKey:@(service)];
						execCommand = YES;
					}
				}
			}
			
			if (execCommand) {
				if (service == PLTServiceWearingState) {
					// wearing state events cant be turned off.
					if (self.wearingStateTimer) {
						[self.wearingStateTimer invalidate];
						self.wearingStateTimer = nil;
					}
				}
				else if(service == PLTServiceProximity) {
					if (self.signalStrengthTimer) {
						[self.signalStrengthTimer invalidate];
						self.signalStrengthTimer = nil;
					}
					
					[self configureSignalStrengthEventsEnabled:NO connectionID:0];
					if (self.remotePort > 0) {
						[self configureSignalStrengthEventsEnabled:NO connectionID:self.remotePort];
					}
				}
				else {
					BRSubscribeToServiceCommand *command = [BRSubscribeToServiceCommand commandWithServiceID:service mode:BRServiceSubscriptionModeOff period:0];
					[self.brSensorsDevice sendMessage:command];
				}
			}
			
			for (id<PLTDeviceSubscriber> s in subscribersToNotify) {
				[s PLTDevice:self didChangeSubscription:oldSubscription toSubscription:nil];
			}
		}
		else {
			DLog(DLogLevelWarn, @"Subscriber is null!");
			// who cares, you're unsubscribed!
		}
	}
	else {
		DLog(DLogLevelWarn, @"Connection not open.");
		// who cares, you're unsubscribed!
	}
}

- (void)unsubscribeFromAll:(id <PLTDeviceSubscriber>)aSubscriber
{
	if (self.isConnectionOpen) {
		
		NSArray *services = self.supportedServices;
		for (NSNumber *service in services) {
			[self unsubscribe:aSubscriber fromService:[service unsignedIntegerValue]];
		}
	}
	else {
		DLog(DLogLevelWarn, @"Connection not open.");
		// who cares, you're unsubscribed!
	}
}

- (void)queryInfo:(id <PLTDeviceSubscriber>)subscriber forService:(PLTService)service error:(NSError **)error
{
	DLog(DLogLevelDebug, @"queryInfo: %@ forService: %lu", subscriber, service);
	
	NSError *connectionNotOpenError = [self checkConnectionOpenError];
	if (connectionNotOpenError) {
		*error = connectionNotOpenError;
		return;
	}
	
	if (subscriber) {
		switch (service) {
			case PLTServiceWearingState:
			case PLTServiceProximity:
			case PLTServiceOrientationTracking:
			case PLTServicePedometer:
			case PLTServiceFreeFall:
			case PLTServiceTaps:
			case PLTServiceMagnetometerCalibrationStatus:
			case PLTServiceGyroscopeCalibrationStatus:
				// cool.
				break;
			default:
				DLog(DLogLevelError, @"Invalid service: %lu", service);
				*error = [NSError errorWithDomain:PLTDeviceErrorDomain
											 code:PLTDeviceErrorInvalidService
										 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
				return;
		}
		
		BOOL execRequest = NO;
		NSMutableArray *subscribers = self.querySubscribers[@(service)];
		
		if (!subscribers) {
			// nobody is waiting for this query right now. add the listener and do the query.
			DLog(DLogLevelDebug, @"Adding new subscriber %@ for service %lu.", subscriber, service);
			
			subscribers = [NSMutableArray array];
			[subscribers addObject:subscriber];
			[self.querySubscribers setObject:subscribers forKey:@(service)];
			execRequest = YES;
		}
		else if (![subscribers containsObject:subscriber]) {
			// somebody is waiting for this query, but listener isn't. add it.
			DLog(DLogLevelDebug, @"Adding subscriber %@ for existing service %lu.", subscriber, service);
			
			if (![subscribers containsObject:subscriber]) {
				[subscribers addObject:subscriber];
			}
			execRequest = YES;
		}
		else {
			// listener is already waiting for the query result. do nothing.
			DLog(DLogLevelDebug, @"Subscriber %@ is already waiting for service %lu.", subscriber, service);
		}
		
		if (execRequest) {
			if (service == PLTServiceWearingState) {
				BRWearingStateSettingRequest *request = (BRWearingStateSettingRequest *)[BRWearingStateSettingRequest request];
				[self.brDevice sendMessage:request];
			}
			else if(service == PLTServiceProximity) {
				// signal strength query wont work unless we're subscribed
				
				PLTSubscription *subscription = self.subscriptions[@(service)];
				//InternalSubscription subscription = _subscriptions.get(service);
				if (subscription) {
					// since signal strength is already configured, we can query it right away
					
					self.waitingForLocalSignalStrengthSettingResponse = YES;
					self.localQuerySignalStrengthResponse = nil;
					
					[self querySignalStrength:0];
					if (self.remotePort > 0) {
						self.waitingForRemoteSignalStrengthSettingResponse = YES;
						self.remoteQuerySignalStrengthResponse = nil;
						[self querySignalStrength:self.remotePort];
					}
				}
				else {
					// since signal strength is not already configured, we have to enable it.
					// wait for the first of each events to come though and use them as the query responses.
					// then, if there are no actual "subscriptions" disable the events.
					
					self.waitingForLocalSignalStrengthEvent = YES;
					self.localQuerySignalStrengthEvent = nil;
					
					[self configureSignalStrengthEventsEnabled:YES connectionID:0];
					if (self.remotePort > 0) {
						self.waitingForRemoteSignalStrengthEvent = YES;
						self.remoteQuerySignalStrengthEvent = nil;
						[self configureSignalStrengthEventsEnabled:YES connectionID:self.remotePort];
					}
				}
			}
			else {
				BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:service];
				[self.brSensorsDevice sendMessage:request];
			}
		}
	}
	else {
		DLog(DLogLevelError, @"Listener is null!");
		*error = [NSError errorWithDomain:PLTDeviceErrorDomain
									 code:PLTDeviceErrorInvalidArgument
								 userInfo:@{NSLocalizedDescriptionKey : @"Subscriber is nil."}];
	}
}

- (PLTInfo *)cachedInfoForService:(PLTService)service error:(NSError **)error
{
	NSError *connectionNotOpenError = [self checkConnectionOpenError];
	if (connectionNotOpenError) {
		*error = connectionNotOpenError;
		return nil;
	}
	
	switch (service) {
		case PLTServiceWearingState:
		case PLTServiceProximity:
		case PLTServiceOrientationTracking:
		case PLTServicePedometer:
		case PLTServiceFreeFall:
		case PLTServiceTaps:
		case PLTServiceMagnetometerCalibrationStatus:
		case PLTServiceGyroscopeCalibrationStatus:
			// cool.
			break;
		default:
			DLog(DLogLevelError, @"Invalid service: %lu", service);
			*error = [NSError errorWithDomain:PLTDeviceErrorDomain
										 code:PLTDeviceErrorInvalidService
									 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
			return nil;
	}
	
	PLTInfo *info = self.cachedInfo[@(service)];
	if (info) {
		info.requestType = PLTInfoRequestTypeCached;
	}
	
	return info;
}

#pragma mark - Private

#ifdef TARGET_OSX
- (PLTDevice *)initWithBluetoothAddress:(NSString *)address
{
	if (self = [super init]) {
		self.address = address;
    }
    return self;
}
#endif

#ifdef TARGET_IOS
- (PLTDevice *)initWithAccessory:(EAAccessory *)anAccessory
{
	if (self = [super init]) {
		self.accessory = anAccessory;
    }
    return self;
}
#endif

- (void)didOpenBRConnection
{
	DLog(DLogLevelInfo, @"didOpenBRConnection");
	
	self.waitingForWearingStatePrimer = NO;
	self.waitingForRemoteSignalStrengthEvent = NO;
	self.waitingForLocalSignalStrengthEvent = false;
	self.localQuerySignalStrengthEvent = nil;
	self.remoteQuerySignalStrengthEvent = nil;
	self.waitingForRemoteSignalStrengthSettingResponse = false;
	self.waitingForLocalSignalStrengthSettingResponse = false;
	self.localQuerySignalStrengthResponse = nil;
	self.remoteQuerySignalStrengthResponse = nil;
	self.queryingOrientationTrackingForCalibration = false;
	self.orientationTrackingCalibration = nil;
	self.pedometerOffset = 0;
	self.queryingOrientationTrackingForCalibration = NO;
	
	// get product name
	BRProductNameSettingRequest *request = (BRProductNameSettingRequest *)[BRProductNameSettingRequest request];
	[self.brDevice sendMessage:request];
}

- (void)didCloseConnection:(BOOL)notify
{
	DLog(DLogLevelInfo, @"didCloseConnection");
	
	//#warning open connection timer
	//	if (self.openConnectionTimer) {
	//		[self.openConnectionTimer invalidate];
	//		self.openConnectionTimer = nil;
	//	}
	
	self.isConnectionOpen = NO;
	self.subscriptions = NO;
	self.querySubscribers = nil;
	self.cachedInfo = nil;
	
	if (self.wearingStateTimer) {
		[self.wearingStateTimer invalidate];
		self.wearingStateTimer = nil;
	}
	
	if (self.signalStrengthTimer) {
		[self.signalStrengthTimer invalidate];
		self.signalStrengthTimer = nil;
	}
	
	self.waitingForRemoteSignalStrengthEvent = NO;
	self.waitingForLocalSignalStrengthEvent = false;
	self.localQuerySignalStrengthEvent = nil;
	self.remoteQuerySignalStrengthEvent = nil;
	self.waitingForRemoteSignalStrengthSettingResponse = false;
	self.waitingForLocalSignalStrengthSettingResponse = false;
	self.localQuerySignalStrengthResponse = nil;
	self.remoteQuerySignalStrengthResponse = nil;
	self.queryingOrientationTrackingForCalibration = false;
	
	if (notify) {
		NSDictionary *userInfo = @{PLTDeviceNotificationKey: self};
		[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceDidCloseConnectionNotification object:nil userInfo:userInfo];
	}
}

- (void)didGetProductName:(BRProductNameSettingResponse *)response
{
	DLog(DLogLevelTrace, @"didGetDeviceInfo:");
	
	self.model = response.name;
	
	self.name = nil;
	if ([self.model isEqualToString:@"4"]) {
		self.name = @"Wearable Concept 1";
	}

	// get serial number
#warning BANGLE FIX
#ifndef BANGLE 
	BRGenesGUIDSettingRequest *request = (BRGenesGUIDSettingRequest *)[BRGenesGUIDSettingRequest request];
	[self.brDevice sendMessage:request];
#else
	[self didFinishHandshake];
#endif
}

- (void)didGetGUID:(BRGenesGUIDSettingResponse *)response
{
	DLog(DLogLevelTrace, @"onGUIDReceived:");
	
	if (response) {
		NSData *guidData = response.guidData;
		uint8_t *guid = malloc([guidData length]);
		[guidData getBytes:guid length:[guidData length]];
		
		NSString *serial = [guidData hexStringWithSpaceEvery:0];
		NSMutableString *hyphenSerial = [NSMutableString string];
		for (int i=0; i<[serial length]; i++) {
			[hyphenSerial appendString:[serial substringWithRange:NSMakeRange(i, 1)]];
			if (i==7 || i==11 || i==15 || i==19) {
				[hyphenSerial appendString:@"-"];
			}
		}
		
		self.serialNumber = hyphenSerial; // example: ACA367C5-E8F1-A64F-954D-F6ED817C7A69 (rev1 no. 057)
	}
	else {
		self.serialNumber = nil;
	}

	// get versions/services info
	BRDeviceInfoSettingRequest *request = (BRDeviceInfoSettingRequest *)[BRDeviceInfoSettingRequest request];
	[self.brSensorsDevice sendMessage:request];
}

- (void)didGetDeviceInfo:(BRDeviceInfoSettingResponse *)response
{
	DLog(DLogLevelTrace, @"didGetDeviceInfo:");
	
	BRDeviceInfoSettingResponse *info = (BRDeviceInfoSettingResponse *)response;
	
	self.hardwareVersion = [NSMutableString string];
	self.firmwareVersion = [NSMutableString string];
	
	for (int v = 0; v<[info.majorHardwareVersions count]; v++) {
		NSString *commaString = ((v == [info.majorHardwareVersions count]-1) ? @"" : @", ");
		[(NSMutableString *)self.hardwareVersion appendFormat:@"%@.%@%@", info.majorHardwareVersions[v], info.minorHardwareVersions[v], commaString];
	}
	
	for (int v = 0; v<[info.majorSoftwareVersions count]; v++) {
		NSString *commaString = ((v == [info.majorSoftwareVersions count]-1) ? @"" : @", ");
		[(NSMutableString *)self.firmwareVersion appendFormat:@"%@.%@%@", info.majorSoftwareVersions[v], info.minorSoftwareVersions[v], commaString];
	}
	
	self.supportedServices = [@[@(PLTServiceWearingState), @(PLTServiceProximity)] mutableCopy];
	[(NSMutableArray *)self.supportedServices addObjectsFromArray:info.supportedServices];
	
//	NSLog(@"self.hardwareVersion: %@", self.hardwareVersion);
//	NSLog(@"self.firmwareVersion: %@", self.firmwareVersion);
//	NSLog(@"self.supportedServices: %@", self.supportedServices);
	
	[self didFinishHandshake];
}

- (void)didFinishHandshake
{
	DLog(DLogLevelInfo, @"didFinishHandshake");
	
	// connection is now "open" for clients
	
	self.subscriptions = [NSMutableDictionary dictionary];
	self.querySubscribers = [NSMutableDictionary dictionary];
	self.cachedInfo = [NSMutableDictionary dictionary];
	
	self.isConnectionOpen = YES;
	
	NSDictionary *userInfo = @{PLTDeviceNotificationKey: self};
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceDidOpenConnectionNotification object:nil userInfo:userInfo];
}

//- (void)didTimeoutOpenConnection:(NSTimer *)aTimer
//{
//	NSLog(@"didTimeoutOpenConnection:");
//	
//	#warning open connection timer
//}

- (void)configureSignalStrengthEventsEnabled:(BOOL)enabled connectionID:(uint8_t)connectionID
{
	DLog(DLogLevelDebug, @"configureSignalStrengthEventsEnabled: %@ connectionID: %d", (enabled?@"YES":@"NO"), connectionID);
	
	BRSubscribeToSignalStrengthCommand *command = [BRSubscribeToSignalStrengthCommand commandWithSubscription:enabled connectionID:connectionID];
	[self.brDevice sendMessage:command];
}

- (void)queryWearingState
{
	// intended only as a "primer" to get cached info for periodic subscriptions.
	
	self.waitingForWearingStatePrimer = YES;
	
	BRWearingStateSettingRequest *request = (BRWearingStateSettingRequest *)[BRWearingStateSettingRequest request];
	[self.brDevice sendMessage:request];
}

- (void)querySignalStrength:(uint8_t)connectionID
{
	DLog(DLogLevelDebug, @"querySignalStrength: %d", connectionID);
	
	BRSignalStrengthSettingRequest *request = [BRSignalStrengthSettingRequest requestWithConnectionID:connectionID];
	[self.brDevice sendMessage:request];
}
					   
- (void)queryOrientationTrackingForCal
{
	DLog(DLogLevelDebug, @"queryOrientationTrackingForCal");
	
	BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:PLTServiceOrientationTracking];
	self.queryingOrientationTrackingForCalibration = YES;
	[self.brSensorsDevice sendMessage:request];
}

- (void)startWearingStateTimer:(uint16_t)period
{
	if (!self.cachedInfo[@(PLTServiceWearingState)]) {
		[self queryWearingState]; // prime the cached info
	}
	
	if (self.wearingStateTimer.isValid) {
		[self.wearingStateTimer invalidate];
	}
	
	self.wearingStateTimer = [NSTimer scheduledTimerWithTimeInterval:((float)period)/1000.0 target:self selector:@selector(wearingStateTimer:) userInfo:nil repeats:YES];
}

- (void)startSignalStrengthTimer:(uint16_t)period
{
	if (self.signalStrengthTimer.isValid) {
		[self.signalStrengthTimer invalidate];
	}
	
	self.signalStrengthTimer = [NSTimer scheduledTimerWithTimeInterval:((float)period)/1000.0 target:self selector:@selector(signalStrengthTimer:) userInfo:nil repeats:YES];
}

- (void)wearingStateTimer:(NSTimer *)aTimer
{
	//DLog(DLogLevelTrace, @"wearingStateTimer:");
	
	PLTSubscription *sub = self.subscriptions[@(PLTServiceWearingState)];
	if (sub && sub.mode==PLTSubscriptionModePeriodic) {
		NSArray *subscribers = sub.subscribers;
		PLTInfo *info = [self cachedInfoForService:PLTServiceWearingState error:nil];
		if (subscribers && info) {
			info.requestType = PLTInfoRequestTypeSubscription;
			info.timestamp = [NSDate date];
			
			for (id <PLTDeviceSubscriber> s in subscribers) {
				[s PLTDevice:self didUpdateInfo:info];
			}
		}
		else {
			DLog(DLogLevelInfo, @"Waiting for wearing info...");
		}
	}
}

- (void)signalStrengthTimer:(NSTimer *)aTimer
{
	//DLog(DLogLevelTrace, @"signalStrengthTimer:");
	
	PLTSubscription *sub = self.subscriptions[@(PLTServiceProximity)];
	if (sub && sub.mode==PLTSubscriptionModePeriodic) {
		NSArray *subscribers = sub.subscribers;
		PLTInfo *info = [self cachedInfoForService:PLTServiceProximity error:nil];
		if (subscribers && info) {
			info.requestType = PLTInfoRequestTypeSubscription;
			info.timestamp = [NSDate date];
			
			for (id <PLTDeviceSubscriber> s in subscribers) {
				[s PLTDevice:self didUpdateInfo:info];
			}
		}
	}
}

- (NSError *)checkConnectionOpenError
{
	if (!self.isConnectionOpen) {
		DLog(DLogLevelError, @"Connection not open.");
		return [NSError errorWithDomain:PLTDeviceErrorDomain
								   code:PLTDeviceErrorConnectionNotOpen
							   userInfo:@{NSLocalizedDescriptionKey : @"Connection not open."}];
	}
	return nil;
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
    DLog(DLogLevelDebug, @"BRDeviceDidConnect: %@", device);
	
	if (device == self.brDevice) {
		// waiting for sensors device at BRDevice:didFindRemoteDevice:
	}
	else if (device == self.brSensorsDevice) {
		[self didOpenBRConnection];
	}
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
    DLog(DLogLevelDebug, @"BRDeviceDidDisconnect: %@", device);
	
	if ((device == self.brDevice) || (device == self.brSensorsDevice)) {
		self.brDevice = nil;
		self.brSensorsDevice = nil;
		[self didCloseConnection:YES];
	}
	else {
		// odd... fixes a bug where 'device' is some random object (that doesn't respond to 'port')
		if (device && [device isKindOfClass:[BRRemoteDevice class]]) {
			uint8_t port = ((BRRemoteDevice *)device).port;
			if (port==0x2 || port==0x3) {
			 DLog(DLogLevelTrace, @"Clearing remote port.");
				self.remotePort = -1;
			}
		}
	}
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
    DLog(DLogLevelError, @"BRDevice: %@ didFailConnectWithError: %d", device, ioBTError);
	
#warning analize + report errors
	
	NSDictionary *userInfo = @{PLTDeviceNotificationKey: self,
							   PLTDeviceConnectionErrorNotificationKey: @(ioBTError)};
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceDidFailOpenConnectionNotification object:nil userInfo:userInfo];
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
    DLog(DLogLevelTrace, @"BRDevice: %@ didReceiveEvent: %@", device, event);
	
	PLTInfoRequestType requestType = PLTInfoRequestTypeSubscription;
	NSDate  *timestamp = [NSDate date];
	PLTInfo *info = nil;
	NSMutableArray *subscribers = [NSMutableArray array];
	PLTService service = -1;
	
	if ([event isKindOfClass:[BROrientationTrackingEvent class]]) {
		service = PLTServiceOrientationTracking;
		BROrientationTrackingEvent *e = (BROrientationTrackingEvent *)event;
		PLTQuaternion quaternion = PLTQuaternionFromBRQuaternion(e.quaternion);
		
		if (self.queryingOrientationTrackingForCalibration) {
			self.orientationTrackingCalibration = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:quaternion];
			self.queryingOrientationTrackingForCalibration = NO;
		}
		
		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
		info = [[PLTOrientationTrackingInfo alloc] initWithRequestType:requestType
															 timestamp:timestamp
														   calibration:self.orientationTrackingCalibration
															quaternion:quaternion];
	}
	else if ([event isKindOfClass:[BRPedometerEvent class]]) {
		service = PLTServicePedometer;
		BRPedometerEvent *e = (BRPedometerEvent *)event;
		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
		info = [[PLTPedometerInfo alloc] initWithRequestType:requestType
												   timestamp:timestamp
												calibration:nil
#warning temporary cal
													   steps:e.steps - self.pedometerOffset];
	}
	else if ([event isKindOfClass:[BRFreeFallEvent class]]) {
		service = PLTServiceFreeFall;
		BRFreeFallEvent *e = (BRFreeFallEvent *)event;
		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
		info = [[PLTFreeFallInfo alloc] initWithRequestType:requestType
												  timestamp:timestamp
												calibration:nil
												   freeFall:e.isInFreeFall];
	}
	else if ([event isKindOfClass:[BRTapsEvent class]]) {
		service = PLTServiceTaps;
		BRTapsEvent *e = (BRTapsEvent *)event;
		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
		info = [[PLTTapsInfo alloc] initWithRequestType:requestType
											  timestamp:timestamp
											calibration:nil
											  direction:e.direction
												  count:e.count];
	}
	else if ([event isKindOfClass:[BRMagnetometerCalStatusEvent class]]) {
		service = PLTServiceMagnetometerCalibrationStatus;
		BRMagnetometerCalStatusEvent *e = (BRMagnetometerCalStatusEvent *)event;
		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
		info = [[PLTMagnetometerCalibrationInfo alloc] initWithRequestType:requestType
																 timestamp:timestamp
															   calibration:nil
														 calibrationStatus:e.isCalibrated];
	}
	else if ([event isKindOfClass:[BRGyroscopeCalStatusEvent class]]) {
		service = PLTServiceGyroscopeCalibrationStatus;
		BRGyroscopeCalStatusEvent *e = (BRGyroscopeCalStatusEvent *)event;
		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
		info = [[PLTGyroscopeCalibrationInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															calibration:nil
													  calibrationStatus:e.isCalibrated];
	}
	else if ([event isKindOfClass:[BRWearingStateEvent class]]) {
		service = PLTServiceWearingState;
		BRWearingStateEvent *e = (BRWearingStateEvent *)event;
		info = [[PLTWearingStateInfo alloc] initWithRequestType:requestType
													  timestamp:timestamp
													calibration:nil
												   wearingState:e.isBeingWorn];
		
		PLTSubscription *subscription = self.subscriptions[@(service)];
		if (subscription) {
			subscribers = subscription.subscribers;
			if (subscription.mode == PLTSubscriptionModeOnChange) {
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
			}
			else {
				self.cachedInfo[@(service)] = info; // cachedInfo is usually set at the bottom, but we just set into to nil.
				info = nil;
				// periodic is taken care of by the _wearingStateTimerTask
			}
		}
	}
	else if ([event isKindOfClass:[BRSignalStrengthEvent class]]) {
		service = PLTServiceProximity;
		BRSignalStrengthEvent *e = (BRSignalStrengthEvent *)event;
		PLTProximityInfo *cachedInfo = (PLTProximityInfo *)self.cachedInfo[@(service)];
		uint8_t connectionID = e.connectionID;
		
		// if temporarily turning on signal strength events, it can take several "unknown" distance events before a near/far value is generated.
		// wait until then to return distance query.
		if (e.distance != PLTProximityUnknown) {
			// check if we're waiting on a signal strength query
			PLTProximityInfo *queryInfo = nil;
			if (connectionID == self.remotePort) {
				//Log.i(FN(), "REMOTE");
				if (self.waitingForRemoteSignalStrengthEvent) {
					//Log.i(FN(), "SET REMOTE INFO");
					self.remoteQuerySignalStrengthEvent = e;
					
					if (self.localQuerySignalStrengthEvent) {
						//Log.i(FN(), "WE GOT LOCAL. DONE.");
						// we're got both.
						queryInfo = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
																   localProximity:self.localQuerySignalStrengthEvent.distance remoteProximity:self.remoteQuerySignalStrengthEvent.distance];
					}
				}
			}
			else {
				//Log.i(FN(), "LOCAL");
				if (self.waitingForLocalSignalStrengthEvent) {
					//Log.i(FN(), "SET LOCAL INFO");
					self.localQuerySignalStrengthEvent = e;
					
					if (self.waitingForRemoteSignalStrengthEvent) {
						//Log.i(FN(), "WAITING ON REMOTE, TOO");
						if (self.remoteQuerySignalStrengthEvent) {
							// we're got both.
							//Log.i(FN(), "WE GOT REMOTE. DONE.");
							queryInfo = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
																	   localProximity:self.localQuerySignalStrengthEvent.distance remoteProximity:self.remoteQuerySignalStrengthEvent.distance];
						}
					}
					else {
						//Log.i(FN(), "WAITING ON LOCAL ONLY. DONE.");
						// not waiting on remote. we've got just the one.
						PLTProximity cachedRemoteProximity = PLTProximityUnknown;
						if (cachedInfo) {
							cachedRemoteProximity = cachedInfo.remoteProximity;
						}
						
						queryInfo = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
																   localProximity:self.localQuerySignalStrengthEvent.distance remoteProximity:cachedRemoteProximity];
					}
				}
			}
			
			if (queryInfo) {
				//Log.i(FN(), "QUERYINFO: " + queryInfo);
				
				NSArray *querySubscribers = self.querySubscribers[@(service)];
				if (querySubscribers) {
					for (id<PLTDeviceSubscriber> s in querySubscribers) {
						[s PLTDevice:self didUpdateInfo:queryInfo];
					}
					
					[self.querySubscribers removeObjectForKey:@(service)];
					self.cachedInfo[@(service)] = queryInfo;
				}
				
				self.waitingForRemoteSignalStrengthEvent = NO;
				self.waitingForLocalSignalStrengthEvent = NO;
				self.localQuerySignalStrengthEvent = nil;
				self.remoteQuerySignalStrengthEvent = nil;
				
				
				PLTSubscription *subscription = self.subscriptions[@(service)];
				if (!subscription) {
					// looks like this was just a query (without otherwise being subscribed)
					// turn off signal strength events
					
					[self configureSignalStrengthEventsEnabled:NO connectionID:0];
					if (self.remotePort > 0) {
						[self configureSignalStrengthEventsEnabled:NO connectionID:self.remotePort];
					}
				}
			}
		}
		
		// process events are normal (not query)
		// this code could be slimmed down a bit (combined with above), but it's simpler to understand as-is
		
		PLTProximity localProximity = PLTProximityUnknown;
		PLTProximity remoteProximity = PLTProximityUnknown;
		if (cachedInfo) {
			localProximity = cachedInfo.localProximity;
			remoteProximity = cachedInfo.remoteProximity;
		}
		
		PLTProximity proximity = (PLTProximity)e.distance; // maps directly
		if (connectionID == self.remotePort) {
			remoteProximity = proximity;
		}
		else {
			localProximity = proximity;
		}
		info = [[PLTProximityInfo alloc] initWithRequestType:requestType
												   timestamp:timestamp
												 calibration:nil
											  localProximity:localProximity
											 remoteProximity:remoteProximity];
		
		PLTSubscription *subscription = self.subscriptions[@(service)];
		if (subscription) {
			if (subscription.mode == PLTSubscriptionModeOnChange) {
				// dont broadcast if its the same!
				PLTProximityInfo *theInfo = (PLTProximityInfo *)info;
				if (cachedInfo && (theInfo.localProximity == cachedInfo.localProximity && theInfo.remoteProximity == cachedInfo.remoteProximity)) {
					DLog(DLogLevelDebug, @"Proximity info is the same. Discarding.");
					info = nil;
				}
				else {
					subscribers = subscription.subscribers;
				}
			}
			else {
				self.cachedInfo[@(service)] = info; // cachedInfo is usually set at the bottom, but we just set into to nil.
				info = nil;
				// periodic is taken care of by the _proximityTimerTask
			}
		}
	}
	
#warning BANGLE
	else if ([event isKindOfClass:[BRSubscribedServiceDataEvent class]]) {
		BRSubscribedServiceDataEvent *serviceDataEvent = (BRSubscribedServiceDataEvent *)event;
		//NSLog(@"service: 0x%04X, characteristic: 0x%04X, data: %@", serviceDataEvent.serviceID, serviceDataEvent.characteristic, [serviceDataEvent.serviceData hexStringWithSpaceEvery:2]);
		
		Class class = nil;
		service = serviceDataEvent.serviceID; // BR IDs map directly to PLTLabs IDs
		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
		
		switch (serviceDataEvent.serviceID) {
			case BRServiceIDSkinTemperature:
				class = [PLTSkinTemperatureInfo class];
				break;
				
			case BRServiceIDAmbientHumidity:
				class = [PLTAmbientHumidityInfo class];
				break;
				
			case BRServiceIDAmbientPressure:
				class = [PLTAmbientPressureInfo class];
				break;
				
			default:
				break;
		}
		
		if (class) {
			info = [[class alloc] initWithRequestType:requestType
											timestamp:timestamp
										  calibration:nil
										  serviceData:serviceDataEvent.serviceData];
		}
	}

	if (info) {
		self.cachedInfo[@(service)] = info;
	}
	
	if (subscribers) {
		for (id<PLTDeviceSubscriber> s in subscribers) {
			[s PLTDevice:self didUpdateInfo:info];
		}
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResponse:(BRSettingResponse *)response
{
    DLog(DLogLevelDebug, @"BRDevice: %@ didReceiveSettingResponse: %@", device, response);
	
	PLTInfoRequestType requestType = PLTInfoRequestTypeQuery;
	NSDate *timestamp = [NSDate date];
	PLTInfo *info = nil;
	int service = -1; // not PLTService because it must be signed
	NSArray *subscribers = nil;
	
	if ([response isKindOfClass:[BROrientationTrackingSettingResponse class]]) {
		BROrientationTrackingSettingResponse *r = (BROrientationTrackingSettingResponse *)response;
		PLTQuaternion quaternion = PLTQuaternionFromBRQuaternion(r.quaternion);
		
		if (self.queryingOrientationTrackingForCalibration) {
			self.orientationTrackingCalibration = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:quaternion];
			self.queryingOrientationTrackingForCalibration = NO;
		}
		else {
			service = PLTServiceOrientationTracking;
			info = [[PLTOrientationTrackingInfo alloc] initWithRequestType:requestType
																 timestamp:timestamp
															   calibration:self.orientationTrackingCalibration
																quaternion:quaternion];
		}
	}
	else if ([response isKindOfClass:[BRTapsSettingResponse class]]) {
		BRTapsSettingResponse *r = (BRTapsSettingResponse *)response;
		service = PLTServiceTaps;
		info = [[PLTTapsInfo alloc] initWithRequestType:requestType
											  timestamp:timestamp
											calibration:nil
											  direction:r.direction
#warning temporary cal
												  count:r.count - self.pedometerOffset];
	}
	else if ([response isKindOfClass:[BRPedometerSettingResponse class]]) {
		BRPedometerSettingResponse *r = (BRPedometerSettingResponse *)response;
		service = PLTServicePedometer;
		info = [[PLTPedometerInfo alloc] initWithRequestType:requestType
												   timestamp:timestamp
												 calibration:nil
													   steps:r.steps];
	}
	else if ([response isKindOfClass:[BRFreeFallSettingResponse class]]) {
		BRFreeFallSettingResponse *r = (BRFreeFallSettingResponse *)response;
		service = PLTServiceFreeFall;
		info = [[PLTFreeFallInfo alloc] initWithRequestType:requestType
												  timestamp:timestamp
												calibration:nil
												   freeFall:r.isInFreeFall];
	}
	else if ([response isKindOfClass:[BRMagnetometerCalStatusSettingResponse class]]) {
		BRMagnetometerCalStatusSettingResponse *r = (BRMagnetometerCalStatusSettingResponse *)response;
		service = PLTServiceMagnetometerCalibrationStatus;
		info = [[PLTMagnetometerCalibrationInfo alloc] initWithRequestType:requestType
																 timestamp:timestamp
															   calibration:nil
														 calibrationStatus:r.isCalibrated];
	}
	else if ([response isKindOfClass:[BRGyroscopeCalStatusSettingResponse class]]) {
		BRGyroscopeCalStatusSettingResponse *r = (BRGyroscopeCalStatusSettingResponse *)response;
		service = PLTServiceGyroscopeCalibrationStatus;
		info = [[PLTGyroscopeCalibrationInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															calibration:nil
													  calibrationStatus:r.isCalibrated];
	}
	else if ([response isKindOfClass:[BRWearingStateSettingResponse class]]) {
		BRWearingStateSettingResponse *r = (BRWearingStateSettingResponse *)response;
		service = PLTServiceWearingState;
		info = [[PLTWearingStateInfo alloc] initWithRequestType:requestType
													  timestamp:timestamp
													calibration:nil
												   wearingState:r.isBeingWorn];
		
		if (self.waitingForWearingStatePrimer) {
			self.waitingForWearingStatePrimer = NO;
			
			info.requestType = PLTInfoRequestTypeCached;
			self.cachedInfo[@(PLTServiceWearingState)] = info;
			info = nil; // probably not necessary since querySubscribers wouldn't have any wearing state listeners...
		}
	}
	else if ([response isKindOfClass:[BRSignalStrengthSettingResponse class]]) {
		BRSignalStrengthSettingResponse *r = (BRSignalStrengthSettingResponse *)response;
		service = PLTServiceProximity;
		
		PLTProximityInfo *cachedInfo = (PLTProximityInfo *)self.cachedInfo[@(service)];
		uint8_t connectionID = r.connectionID;
		
		// check if we're waiting on a signal strength query
		if (connectionID == self.remotePort) {
			//Log.i(FN(), "REMOTE");
			if (self.waitingForRemoteSignalStrengthSettingResponse) {
				//Log.i(FN(), "SET REMOTE INFO");
				self.remoteQuerySignalStrengthResponse = r;
				
				if (self.localQuerySignalStrengthResponse) {
					//Log.i(FN(), "WE GOT LOCAL. DONE.");
					// we're got both.
					info = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
															   localProximity:self.localQuerySignalStrengthEvent.distance remoteProximity:self.remoteQuerySignalStrengthEvent.distance];
				}
			}
		}
		else {
			//Log.i(FN(), "LOCAL");
			if (self.waitingForLocalSignalStrengthSettingResponse) {
				//Log.i(FN(), "SET LOCAL INFO");
				self.localQuerySignalStrengthResponse = r;
				
				if (self.waitingForRemoteSignalStrengthSettingResponse) {
					//Log.i(FN(), "WAITING ON REMOTE, TOO");
					if (self.remoteQuerySignalStrengthResponse) {
						//Log.i(FN(), "WE GOT REMOTE. DONE.");
						// we're got both.
						info = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
															  localProximity:self.localQuerySignalStrengthEvent.distance remoteProximity:self.remoteQuerySignalStrengthEvent.distance];
					}
				}
				else {
					//Log.i(FN(), "WAITING ON LOCAL ONLY. DONE.");
					// not waiting on remote. we've got just the one.
					PLTProximity cachedRemoteProximity = PLTProximityUnknown;
					if (cachedInfo) {
						cachedRemoteProximity = cachedInfo.remoteProximity;
					}
					
					info = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
														  localProximity:self.localQuerySignalStrengthEvent.distance remoteProximity:cachedRemoteProximity];
				}
			}
		}
		
		if (info) {
			//Log.d(FN(),"INFO: " + info);
			self.waitingForRemoteSignalStrengthSettingResponse = NO;
			self.waitingForLocalSignalStrengthSettingResponse = NO;
			self.localQuerySignalStrengthResponse = nil;
			self.remoteQuerySignalStrengthResponse = nil;
		}
	}
	else if ([response isKindOfClass:[BRDeviceInfoSettingResponse class]]) {
		[self didGetDeviceInfo:(BRDeviceInfoSettingResponse *)response];
    }
	else if ([response isKindOfClass:[BRGenesGUIDSettingResponse class]]) {
		[self didGetGUID:(BRGenesGUIDSettingResponse *)response];
	}
	else if ([response isKindOfClass:[BRProductNameSettingResponse class]]) {
		[self didGetProductName:(BRProductNameSettingResponse *)response];
	}
	
	subscribers = self.querySubscribers[@(service)];
	
	if (info && service > -1) {
		self.cachedInfo[@(service)] = info;
		
		if (subscribers) {
			for (id<PLTDeviceSubscriber> s in subscribers) {
				[s PLTDevice:self didUpdateInfo:info];
			}
		}
		
		[self.querySubscribers removeObjectForKey:@(service)];
	}
}

- (void)BRDevice:(BRDevice *)device didRaiseSettingException:(BRException *)exception
{
    DLog(DLogLevelError, @"BRDevice: %@ didRaiseSettingException: %@", device, exception);
	
	uint16_t exceptionID = exception.exceptionID;
	if (exceptionID == 0x0A1E) {
		if (!self.isConnectionOpen) { // really we should have states for all steps in the handshake... maybe add this later...
			[self didGetGUID:nil];
		}
	}
}

- (void)BRDevice:(BRDevice *)device didRaiseCommandException:(BRException *)exception
{
	DLog(DLogLevelError, @"BRDevice: %@ didRaiseCommandException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice
{
	DLog(DLogLevelDebug, @"BRDevice: %@ didFindRemoteDevice: %@", device, remoteDevice);
	
	uint8_t port = remoteDevice.port;
	
	if (port == 0x5) {
		self.brSensorsDevice = remoteDevice;
		self.brSensorsDevice.delegate = self;
		[self.brSensorsDevice openConnection];
	}
	else if (port==0x2 || port==0x3) {
		DLog(DLogLevelTrace, @"Setting remote port to %d", port);
		self.remotePort = port;
		
		// if somebody is already subscribed to proximity, we need to configure the HS to send remote port events as well now
		PLTSubscription *sub = self.subscriptions[@(PLTServiceProximity)];
		if (sub) {
			[self configureSignalStrengthEventsEnabled:YES connectionID:self.remotePort];
		}
	}
}

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
    NSString *hexString = [data hexStringWithSpaceEvery:2];
    DLog(DLogLevelTrace, @"--> %@", hexString);
	
	NSDictionary *userInfo = @{PLTDeviceDataNotificationKey: data};
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceWillSendDataNotification object:nil userInfo:userInfo];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
    NSString *hexString = [data hexStringWithSpaceEvery:2];
    DLog(DLogLevelTrace, @"<-- %@", hexString);
	
	NSDictionary *userInfo = @{PLTDeviceDataNotificationKey: data};
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceDidReceiveDataNotification object:nil userInfo:userInfo];
}

#pragma mark - NSObject


- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[PLTDevice class]]) {
#ifdef TARGET_OSX
		return [((PLTDevice *)object).address isEqualToString:self.address];
		
#endif
#ifdef TARGET_IOS
		return ((PLTDevice *)object).accessory.connectionID == self.accessory.connectionID;
#endif
	}
	return NO;
}

- (NSString *)description
{
#ifdef TARGET_OSX
	return [NSString stringWithFormat:@"<PLTDevice: %p> address=%@, model=%@, name=%@, serialNumber=%@, hardwareVersion=%@, firmwareVersion=%@, supportedServices=%@, isConnectionOpen=%@",
			self, self.address, self.model, self.name, self.serialNumber, self.hardwareVersion, self.firmwareVersion, [self.supportedServices hexDescriptionFromShortIntegerArray], (self.isConnectionOpen ? @"YES" : @"NO")];	
#endif
#ifdef TARGET_IOS
	return [NSString stringWithFormat:@"<PLTDevice: %p> model=%@, name=%@, serialNumber=%@, hardwareVersion=%@, firmwareVersion=%@, supportedServices=%@, isConnectionOpen=%@",
			self, self.model, self.name, self.serialNumber, self.hardwareVersion, self.firmwareVersion, [self.supportedServices hexDescriptionFromShortIntegerArray], (self.isConnectionOpen ? @"YES" : @"NO")];
#endif
}

@end


@implementation PLTSubscription

#pragma mark - Public

+ (PLTSubscription *)subscriptionWithService:(PLTService)service mode:(PLTSubscriptionMode)mode period:(uint16_t)period subscriber:(id<PLTDeviceSubscriber>)subscriber
{
	PLTSubscription *subscription = [[PLTSubscription alloc] init];
	subscription.service = service;
	subscription.mode = mode;
	subscription.period = period;
	subscription.subscribers = [@[subscriber] mutableCopy];
	return subscription;
}

+ (PLTSubscription *)subscriptionWithService:(PLTService)service mode:(PLTSubscriptionMode)mode period:(uint16_t)period subscribers:(NSArray *)subscribers
{
	PLTSubscription *subscription = [[PLTSubscription alloc] init];
	subscription.service = service;
	subscription.mode = mode;
	subscription.period = period;
	subscription.subscribers = [subscribers mutableCopy];
	return subscription;
}

- (void)addSubscriber:(id<PLTDeviceSubscriber>)subscriber
{
	[self removeSubscriber:subscriber];
	if (![self.subscribers containsObject:subscriber]) {
		[self.subscribers addObject:subscriber];
	}
}

- (void)removeSubscriber:(id<PLTDeviceSubscriber>)subscriber
{
	[self.subscribers removeObject:subscriber];
}

- (NSString *)privateDescription
{
	return [NSString stringWithFormat:@"<PLTInternalSubscription %p> service=0x%04lX, mode=0x%02lX, period=0x%04X, subscribers=%@",
			self, self.service, self.mode, self.period, self.subscribers];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTSubscription %p> service=0x%04lX, mode=0x%02lX, period=0x%04X",
			self, self.service, self.mode, self.period];
}

@end

