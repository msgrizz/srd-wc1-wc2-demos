//
//  PLTDevice.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "BRDevice.h"
#import "PLTDeviceConfiguration.h"
#import "PLTDLog.h"
#import "BRDeviceWatcher.h"
#import "BRDevice_Private.h"

#ifdef TARGET_OSX
#import "PLTDevice_OSX.h"
#import "BRDevice_OSX.h"
#import <CoreServices/CoreServices.h>
#endif
#ifdef TARGET_IOS
#import "PLTDevice_iOS.h"
#import "BRDevice_iOS.h"
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
#import "PLTAccelerationInfo_Internal.h"
#import "PLTAngularVelocityInfo_Internal.h"
#import "PLTMagnetismInfo_Internal.h"
#import "PLTHeadingInfo_Internal.h"

#warning BANGLE
#import "PLTDevice_Bangle.h"
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


@interface PLTSubscription ()

+ (PLTSubscription *)subscriptionWithService:(PLTService)service mode:(PLTSubscriptionMode)mode period:(uint16_t)period subscriber:(id<PLTDeviceSubscriber>)subscriber;
+ (PLTSubscription *)subscriptionWithService:(PLTService)service mode:(PLTSubscriptionMode)mode period:(uint16_t)period subscribers:(NSArray *)subscribers;
- (void)addSubscriber:(id<PLTDeviceSubscriber>)subscriber;
- (void)removeSubscriber:(id<PLTDeviceSubscriber>)subscriber;
- (NSString *)privateDescription;

@property(nonatomic,assign,readwrite)	PLTService					service;
@property(nonatomic,assign,readwrite)	PLTSubscriptionMode			mode;
@property(nonatomic,assign,readwrite)	uint16_t					period;
@property(nonatomic,strong,readwrite)	NSMutableArray				*subscribers;

@end


@interface PLTDevice() <BRDeviceDelegate>

- (void)didOpenBRConnection;
- (void)didCloseConnection:(BOOL)notify;
- (void)didGetProductName:(BRProductNameSettingResult *)result;
- (void)didGetGUID:(BRGenesGUIDSettingResult *)result;
- (void)didGetDeviceInfo:(BRGetDeviceInfoSettingResult *)result;
- (void)didFinishHandshake;
- (BOOL)isServiceSupported:(PLTService)service;
- (void)configureSignalStrengthEventsEnabled:(BOOL)enabled connectionID:(uint8_t)connectionID;
- (void)queryWearingState;
- (void)querySignalStrength:(uint8_t)connectionID;
- (void)startWearingStateTimer:(uint16_t)period;
- (void)startSignalStrengthTimer:(uint16_t)period;
- (void)wearingStateTimer:(NSTimer *)aTimer;
- (void)signalStrengthTimer:(NSTimer *)aTimer;
- (NSError *)connectionNotOpenError;
- (PLTQuaternion)quaternionFromServiceData:(NSData *)serviceData;
- (BOOL)checkQuaternion:(PLTQuaternion)quaternion;
- (uint32_t)pedometerCountFromServiceData:(NSData *)serviceData;
- (BOOL)freeFallFromServiceData:(NSData *)serviceData;
- (void)getTapsFromServiceData:(NSData *)serviceData count:(uint8_t *)count direction:(uint8_t *)direction;
- (BOOL)calibrationFromServiceData:(NSData *)serviceData;

@property(nonatomic,strong)				BRDevice								*brSensorsDevice;
@property(nonatomic,readwrite)			BOOL									isConnectionOpen;
@property(nonatomic,strong)				NSMutableDictionary						*subscriptions;
@property(nonatomic,strong)				NSMutableDictionary						*querySubscribers;
@property(nonatomic,strong)				NSMutableDictionary						*cachedInfo;

//#ifdef TARGET_OSX
@property(nonatomic,strong,readwrite)	NSString								*address;
//#endif
@property(nonatomic,strong,readwrite)	NSString								*model;
@property(nonatomic,strong,readwrite)	NSString								*name;
@property(nonatomic,strong,readwrite)	NSString								*serialNumber;
@property(nonatomic,strong,readwrite)	NSString								*hardwareVersion;
@property(nonatomic,strong,readwrite)	NSString								*firmwareVersion;

@property(nonatomic,strong,readwrite)	NSArray									*supportedServices;

@property(nonatomic,assign)				int8_t									remotePort;
@property(nonatomic,strong)				NSTimer									*wearingStateTimer;
@property(nonatomic,strong)				NSTimer									*signalStrengthTimer;

@property(nonatomic,assign)				BOOL									waitingForWearingStatePrimer;
@property(nonatomic,assign)				BOOL									waitingForRemoteSignalStrengthEvent;
@property(nonatomic,assign)				BOOL									waitingForLocalSignalStrengthEvent;
@property(nonatomic,strong)				BRSignalStrengthEvent					*localQuerySignalStrengthEvent;
@property(nonatomic,strong)				BRSignalStrengthEvent					*remoteQuerySignalStrengthEvent;
@property(nonatomic,assign)				BOOL									waitingForRemoteSignalStrengthSettingResult;
@property(nonatomic,assign)				BOOL									waitingForLocalSignalStrengthSettingResult;
@property(nonatomic,strong)				BRCurrentSignalStrengthSettingResult	*localQuerySignalStrengthResult;
@property(nonatomic,strong)				BRCurrentSignalStrengthSettingResult	*remoteQuerySignalStrengthResult;

#warning reset these on open/close/whatever
@property(nonatomic,strong)				PLTOrientationTrackingCalibration		*orientationCalibration;
@property(nonatomic,assign)				NSUInteger								pedometerOffset;
@property(nonatomic,assign)				BOOL									queryingOrientationForCalibration;

@end


@implementation PLTDevice

#pragma mark - Public

+ (NSArray *)availableDevices
{
	[PLTDLogger sharedLogger];
	
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
	if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
		[NSException raise:@"Incompatible OS version"
					format:@"PLTDevice is not compatible with this version of iOS (%@). Please install iOS 8.0 or later.", [[UIDevice currentDevice] systemVersion]];
	}
	#if TARGET_IPHONE_SIMULATOR
	NSLog(@"*** Note: PLTDevice is running in iOS Simulator, therefore device connectivity will not function. To enable this functionality please run your app on an actual iOS device. ***");
	#endif
#endif
	
//	if (![[NSData data] respondsToSelector:@selector(hexStringWithSpaceEvery:)]) {
//		[NSException raise:@"PLT categories not found"
//					format:@"PLT categories don't appear to be loaded. Make sure to link with the \"-ObjC\" linker flag."];
//	}
	
	return [PLTDeviceWatcher sharedWatcher].devices;
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
	#ifdef TERSE_LOGGING
		DLog(DLogLevelInfo, @"Connecting to accessory %@...", self.accessory.name);
	#else
		DLog(DLogLevelInfo, @"Connecting to accessory %@...", self.accessory);
	#endif
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
	
	NSError *connectionNotOpenError = [self connectionNotOpenError];
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
	NSError *connectionNotOpenError = [self connectionNotOpenError];
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
	
	NSError *connectionNotOpenError = [self connectionNotOpenError];
	if (!connectionNotOpenError) {
		switch (service) {
			case PLTServiceOrientation: {
				PLTOrientationTrackingCalibration *theCal = nil;
				
				if (!cal) {
					PLTOrientationTrackingInfo *orientationInfo = (PLTOrientationTrackingInfo *)self.cachedInfo[@(service)];
					if (orientationInfo) {
						theCal = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:orientationInfo.uncalibratedQuaternion];
					}
				}
				if (theCal) {
					_orientationCalibration = theCal;
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
	else {
		*error = connectionNotOpenError;
	}
}

- (PLTCalibration *)calibrationForService:(PLTService)theService error:(NSError **)error
{
	NSError *connectionNotOpenError = [self connectionNotOpenError];
	if (!connectionNotOpenError) {
		if (theService == PLTServiceOrientation) {
			return (PLTCalibration *)self.orientationCalibration;
		}
		else {
			*error = [NSError errorWithDomain:PLTDeviceErrorDomain
										 code:PLTDeviceErrorInvalidService
									 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
		}
	}
	else {
		*error = connectionNotOpenError;
	}
	return nil;
}

- (void)subscribe:(id <PLTDeviceSubscriber>)subscriber toService:(PLTService)service withMode:(PLTSubscriptionMode)mode andPeriod:(NSUInteger)period error:(NSError **)error
{
	DLog(DLogLevelInfo, @"subscribe: %@ toService: 0x%04X withMode: %lu minPeriod: %lu", subscriber, service, mode, (unsigned long)period);
	
	NSError *connectionNotOpenError = [self connectionNotOpenError];
	if (!connectionNotOpenError) {
		if (subscriber != nil) {
			if ([self isServiceSupported:service]) {
				if (mode==PLTSubscriptionModeOnChange || mode==PLTSubscriptionModePeriodic) {
					
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
							
							BRSubscribeToServicesCommand *command = [BRSubscribeToServicesCommand commandWithServiceID:newSubscription.service
																										characteristic:0
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
					DLog(DLogLevelError, @"Invalid subscription mode: %lu", mode);
					*error = [NSError errorWithDomain:PLTDeviceErrorDomain
												 code:PLTDeviceErrorInvalidMode
											 userInfo:@{NSLocalizedDescriptionKey : @"Invalid subscription mode."}];
				}
			}
			else {
				DLog(DLogLevelError, @"Invalid service: %lu", service);
				*error = [NSError errorWithDomain:PLTDeviceErrorDomain
											 code:PLTDeviceErrorInvalidService
										 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
			}
		}
		else {
			DLog(DLogLevelError, @"Subscriber is nil!");
			*error = [NSError errorWithDomain:PLTDeviceErrorDomain
										 code:PLTDeviceErrorInvalidArgument
									 userInfo:@{NSLocalizedDescriptionKey : @"Subscriber is nil."}];
		}
	}
	else {
		*error = connectionNotOpenError;
	}
}

- (void)unsubscribe:(id <PLTDeviceSubscriber>)subscriber fromService:(PLTService)service
{
	DLog(DLogLevelDebug, @"unsubscribe: %@ fromService: %lu", subscriber, service);
	
	NSError *connectionNotOpenError = [self connectionNotOpenError];
	if (!connectionNotOpenError) {
		if (subscriber) {
			if ([self isServiceSupported:service]) {
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
						BRSubscribeToServicesCommand *command = [BRSubscribeToServicesCommand commandWithServiceID:service
																									characteristic:0
																											  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																											period:0];
						[self.brSensorsDevice sendMessage:command];
					}
				}
				
				for (id<PLTDeviceSubscriber> s in subscribersToNotify) {
					[s PLTDevice:self didChangeSubscription:oldSubscription toSubscription:nil];
				}
			}
			else {
				DLog(DLogLevelWarn, @"Invalid service: %lu", service);
				// who cares, you're unsubscribed!
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
	NSError *connectionNotOpenError = [self connectionNotOpenError];
	if (!connectionNotOpenError) {
		NSMutableArray *services = [self.supportedServices mutableCopy];
#ifdef WC2
		[services addObject:@(PLTServiceHeading)];
		[services addObject:@(PLTServiceAcceleration)];
		[services addObject:@(PLTServiceAngularVelocity)];
		[services addObject:@(PLTServiceMagnetism)];
#endif
		for (NSNumber *service in services) {
			[self unsubscribe:aSubscriber fromService:[service unsignedShortValue]];
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
	
	NSError *connectionNotOpenError = [self connectionNotOpenError];
	if (!connectionNotOpenError) {
		if (subscriber) {
			if ([self isServiceSupported:service]) {
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
							
							self.waitingForLocalSignalStrengthSettingResult = YES;
							self.localQuerySignalStrengthResult = nil;
							
							[self querySignalStrength:0];
							if (self.remotePort > 0) {
								self.waitingForRemoteSignalStrengthSettingResult = YES;
								self.remoteQuerySignalStrengthResult = nil;
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
						BRQueryServicesDataSettingRequest *request = [BRQueryServicesDataSettingRequest requestWithServiceID:service characteristic:0];
						[self.brSensorsDevice sendMessage:request];
					}
				}
			}
			else {
				DLog(DLogLevelError, @"Invalid service: %lu", service);
				*error = [NSError errorWithDomain:PLTDeviceErrorDomain
											 code:PLTDeviceErrorInvalidService
										 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
			}
		}
		else {
			DLog(DLogLevelError, @"Subscriber is nil!");
			*error = [NSError errorWithDomain:PLTDeviceErrorDomain
										 code:PLTDeviceErrorInvalidArgument
									 userInfo:@{NSLocalizedDescriptionKey : @"Subscriber is nil."}];
		}
	}
	else {
		*error = connectionNotOpenError;
	}
}

- (PLTInfo *)cachedInfoForService:(PLTService)service error:(NSError **)error
{
	NSError *connectionNotOpenError = [self connectionNotOpenError];
	if (!connectionNotOpenError) {
		if ([self isServiceSupported:service]) {
			PLTInfo *info = self.cachedInfo[@(service)];
			if (info) {
				info.requestType = PLTInfoRequestTypeCached;
			}
			return info;
		}
		else {
			DLog(DLogLevelError, @"Invalid service: %lu", service);
			*error = [NSError errorWithDomain:PLTDeviceErrorDomain
										 code:PLTDeviceErrorInvalidService
									 userInfo:@{NSLocalizedDescriptionKey : @"Invalid service."}];
		}
	}
	else {
		*error = connectionNotOpenError;
	}
	
	return nil;
}

#pragma mark - Private

+ (PLTDevice *)deviceWithBRDevice:(BRDevice *)brDevice
{
	PLTDevice *pltDevice = [[PLTDevice alloc] init];
	if (pltDevice) {
		pltDevice.brDevice = brDevice;
#ifdef TARGET_OSX
		pltDevice.address = brDevice.bluetoothAddress;
#endif
#ifdef TARGET_IOS
		pltDevice.accessory = brDevice.accessory;
#endif
	}
	return pltDevice;
}

//#ifdef TARGET_OSX
//- (PLTDevice *)initWithBluetoothAddress:(NSString *)address
//{
//	if (self = [super init]) {
//		self.address = address;
//    }
//    return self;
//}
//#endif
//
//#ifdef TARGET_IOS
//- (PLTDevice *)initWithAccessory:(EAAccessory *)anAccessory
//{
//	if (self = [super init]) {
//		self.accessory = anAccessory;
//    }
//    return self;
//}
//#endif

- (void)didOpenBRConnection
{
	DLog(DLogLevelInfo, @"didOpenBRConnection");
	
	self.waitingForWearingStatePrimer = NO;
	self.waitingForRemoteSignalStrengthEvent = NO;
	self.waitingForLocalSignalStrengthEvent = false;
	self.localQuerySignalStrengthEvent = nil;
	self.remoteQuerySignalStrengthEvent = nil;
	self.waitingForRemoteSignalStrengthSettingResult = false;
	self.waitingForLocalSignalStrengthSettingResult = false;
	self.localQuerySignalStrengthResult = nil;
	self.remoteQuerySignalStrengthResult = nil;
	self.queryingOrientationForCalibration = false;
	self.orientationCalibration = nil;
	self.pedometerOffset = 0;
	self.queryingOrientationForCalibration = NO;
	
	// get product name
	BRProductNameSettingRequest *request = (BRProductNameSettingRequest *)[BRProductNameSettingRequest request];
	[self.brDevice sendMessage:request];
}

- (void)didCloseConnection:(BOOL)notify
{
	DLog(DLogLevelInfo, @"didCloseConnection");

	self.isConnectionOpen = NO;
	self.subscriptions = nil;
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
	self.waitingForRemoteSignalStrengthSettingResult = false;
	self.waitingForLocalSignalStrengthSettingResult = false;
	self.localQuerySignalStrengthResult = nil;
	self.remoteQuerySignalStrengthResult = nil;
	self.queryingOrientationForCalibration = false;
	
	if (notify) {
		NSDictionary *userInfo = @{PLTDeviceNotificationKey: self};
		[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceDidCloseConnectionNotification object:nil userInfo:userInfo];
	}
}

- (void)didGetProductName:(BRProductNameSettingResult *)result
{
	DLog(DLogLevelTrace, @"didGetDeviceInfo:");
	
	self.model = result.productName;
	
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

- (void)didGetGUID:(BRGenesGUIDSettingResult *)result
{
	DLog(DLogLevelTrace, @"onGUIDReceived:");
	
	if (result) {
		NSData *guidData = result.guid;
		uint8_t *guid = malloc([guidData length]);
		[guidData getBytes:guid length:[guidData length]];
		
		NSString *serial = BRDeviceHexStringFromData(guidData, 0);
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
	BRGetDeviceInfoSettingRequest *request = (BRGetDeviceInfoSettingRequest *)[BRGetDeviceInfoSettingRequest request];
	[self.brSensorsDevice sendMessage:request];
}

- (void)didGetDeviceInfo:(BRGetDeviceInfoSettingResult *)result
{
	DLog(DLogLevelTrace, @"didGetDeviceInfo:");
	
	BRGetDeviceInfoSettingResult *info = (BRGetDeviceInfoSettingResult *)result;
	
	// this is a weird mix of how the "old" (hand-written) BR object parsed the data and the existing code to further process it externally...
	
	NSMutableArray *majorHardwareVersions = [NSMutableArray array];
	NSMutableArray *minorHardwareVersions = [NSMutableArray array];
	NSMutableArray *majorSoftwareVersions = [NSMutableArray array];
	NSMutableArray *minorSoftwareVersions = [NSMutableArray array];
	NSMutableArray *supportedServices = [NSMutableArray array];
	
	enum DeviceInfo {
		DeviceInfoMajorHWVersion = 0,
		DeviceInfoMinorHWVersion,
		DeviceInfoMajorSWVersion,
		DeviceInfoMinorSWVersion,
		DeviceInfoSupportedServices
	};
	
	uint16_t offset = 2;
	uint16_t len = 0;
	uint8_t *vers;
	
	for (enum DeviceInfo i = DeviceInfoMajorHWVersion; i < DeviceInfoSupportedServices; i++) {
		
		[[info.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
		len = ntohs(len);
		
		offset += sizeof(uint16_t);
		
		vers = malloc(len);
		[[info.payload subdataWithRange:NSMakeRange(offset, len)] getBytes:vers length:len];
		
		for (int v=0; v<len; v++) {
			uint8_t version = vers[v];
			switch (i) {
				case DeviceInfoMajorHWVersion:
					[majorHardwareVersions addObject:@(version)];
					break;
				case DeviceInfoMinorHWVersion:
					[minorHardwareVersions addObject:@(version)];
					break;
				case DeviceInfoMajorSWVersion:
					[majorSoftwareVersions addObject:@(version)];
					break;
				case DeviceInfoMinorSWVersion:
					[minorSoftwareVersions addObject:@(version)];
					break;
				case DeviceInfoSupportedServices: // suppress compiler warnings
					break;
			}
		}
		
		free(vers);
		
		offset += len;
	}
	
	[[info.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
	len = ntohs(len);
	
	offset += sizeof(uint16_t);
	
	uint16_t services[len];
	[[info.payload subdataWithRange:NSMakeRange(offset, len)] getBytes:&services length:len];
	
	for (int s=0; s<(len/2); s++) {
		[supportedServices addObject:@(htons(services[s]))];
	}

	// previous start to this method before "new" BR library
	
	self.hardwareVersion = [NSMutableString string];
	self.firmwareVersion = [NSMutableString string];
	
	for (int v = 0; v<[majorHardwareVersions count]; v++) {
		NSString *commaString = ((v == [majorHardwareVersions count]-1) ? @"" : @", ");
		[(NSMutableString *)self.hardwareVersion appendFormat:@"%@.%@%@", majorHardwareVersions[v], minorHardwareVersions[v], commaString];
	}
	
	for (int v = 0; v<[majorSoftwareVersions count]; v++) {
		NSString *commaString = ((v == [majorSoftwareVersions count]-1) ? @"" : @", ");
		[(NSMutableString *)self.firmwareVersion appendFormat:@"%@.%@%@", majorSoftwareVersions[v], minorSoftwareVersions[v], commaString];
	}
	
	self.supportedServices = [@[@(PLTServiceWearingState), @(PLTServiceProximity)] mutableCopy];
	[(NSMutableArray *)self.supportedServices addObjectsFromArray:supportedServices];
	
	[self didFinishHandshake];
}

//- (void)didGetDeviceInfo:(BRGetDeviceInfoSettingResult *)result
//{
//	DLog(DLogLevelTrace, @"didGetDeviceInfo:");
//	
//	BRGetDeviceInfoSettingResult *info = (BRGetDeviceInfoSettingResult *)result;
//
//	self.hardwareVersion = [NSMutableString string];
//	self.firmwareVersion = [NSMutableString string];
//	
//	for (int v = 0; v<[info.majorHardwareVersions count]; v++) {
//		NSString *commaString = ((v == [info.majorHardwareVersions count]-1) ? @"" : @", ");
//		[(NSMutableString *)self.hardwareVersion appendFormat:@"%@.%@%@", info.majorHardwareVersions[v], info.minorHardwareVersions[v], commaString];
//	}
//	
//	for (int v = 0; v<[info.majorSoftwareVersions count]; v++) {
//		NSString *commaString = ((v == [info.majorSoftwareVersions count]-1) ? @"" : @", ");
//		[(NSMutableString *)self.firmwareVersion appendFormat:@"%@.%@%@", info.majorSoftwareVersions[v], info.minorSoftwareVersions[v], commaString];
//	}
//	
//	self.supportedServices = [@[@(PLTServiceWearingState), @(PLTServiceProximity)] mutableCopy];
//	[(NSMutableArray *)self.supportedServices addObjectsFromArray:info.supportedServices];
//	
//	[self didFinishHandshake];
//}

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

- (BOOL)isServiceSupported:(PLTService)service
{
	switch (service) {
		case PLTServiceWearingState:
		case PLTServiceProximity:
		case PLTServiceOrientation:
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
#ifdef WC2
		case PLTServiceHeading:
		case PLTServiceAcceleration:
		case PLTServiceAngularVelocity:
		case PLTServiceMagnetism:
#endif
			return YES;
	}
	return NO;
}

- (void)configureSignalStrengthEventsEnabled:(BOOL)enabled connectionID:(uint8_t)connectionID
{
	DLog(DLogLevelDebug, @"configureSignalStrengthEventsEnabled: %@ connectionID: %d", (enabled?@"YES":@"NO"), connectionID);
	
	BRConfigureSignalStrengthEventsCommand *command = [BRConfigureSignalStrengthEventsCommand commandWithConnectionId:connectionID
																											   enable:YES
																											  dononly:NO
																												trend:NO
																									  reportRssiAudio:NO 
																								   reportNearFarAudio:NO
																								  reportNearFarToBase:NO 
																										  sensitivity:0
																										nearThreshold:71
																										   maxTimeout:UINT16_MAX];
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
	
	BRCurrentSignalStrengthSettingRequest *request = [BRCurrentSignalStrengthSettingRequest requestWithConnectionId:connectionID];
	[self.brDevice sendMessage:request];
}
					   
- (void)queryOrientationTrackingForCal
{
	DLog(DLogLevelDebug, @"queryOrientationTrackingForCal");
	
	BRQueryServicesDataSettingRequest *request = [BRQueryServicesDataSettingRequest requestWithServiceID:PLTServiceOrientation
																						  characteristic:0];
	self.queryingOrientationForCalibration = YES;
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

- (NSError *)connectionNotOpenError
{
	if (!self.isConnectionOpen) {
		DLog(DLogLevelError, @"Connection not open.");
		return [NSError errorWithDomain:PLTDeviceErrorDomain
								   code:PLTDeviceErrorConnectionNotOpen
							   userInfo:@{NSLocalizedDescriptionKey : @"Connection not open."}];
	}
	return nil;
}

#pragma mark - WC1 Parsing Helpers

- (PLTQuaternion)quaternionFromServiceData:(NSData *)serviceData
{
	int32_t w, x, y, z;
	
	[[serviceData subdataWithRange:NSMakeRange(0, sizeof(int32_t))] getBytes:&w length:sizeof(int32_t)];
	[[serviceData subdataWithRange:NSMakeRange(4, sizeof(int32_t))] getBytes:&x length:sizeof(int32_t)];
	[[serviceData subdataWithRange:NSMakeRange(8, sizeof(int32_t))] getBytes:&y length:sizeof(int32_t)];
	[[serviceData subdataWithRange:NSMakeRange(12, sizeof(int32_t))] getBytes:&z length:sizeof(int32_t)];
	
	w = ntohl(w);
	x = ntohl(x);
	y = ntohl(y);
	z = ntohl(z);
	
	if (w > 32767) w -= 65536;
	if (x > 32767) x -= 65536;
	if (y > 32767) y -= 65536;
	if (z > 32767) z -= 65536;
	
	double fw = ((double)w) / 16384.0f;
	double fx = ((double)x) / 16384.0f;
	double fy = ((double)y) / 16384.0f;
	double fz = ((double)z) / 16384.0f;
	
	return (PLTQuaternion){fw, fx, fy, fz};
}

- (BOOL)checkQuaternion:(PLTQuaternion)quaternion
{
	PLTQuaternion absQuaternion = {fabs(quaternion.x),fabs(quaternion.y),fabs(quaternion.z),fabs(quaternion.w)};
	if (absQuaternion.x<.00001 || absQuaternion.y<.00001 || absQuaternion.z<.00001 || absQuaternion.w<.00001) {
		DLog(DLogLevelError, @"*** BAD QUATERNION! ***");
		return NO;
	}
	return YES;
}

//- (PLTDeviceVec3)vec3FromServiceData:(NSData *)serviceData
//{
//	float d = exp2f(16);
//	PLTDeviceVec3 v3;
//	
//	[serviceData getBytes:&v3 length:sizeof(v3)];
//	
//	return (PLTDeviceVec3) {
//		((float)v3.x)/d,
//		((float)v3.y)/d,
//		((float)v3.z)/d };
//}

- (uint32_t)pedometerCountFromServiceData:(NSData *)serviceData
{
	uint32_t steps;
	[serviceData getBytes:&steps length:sizeof(uint32_t)];
	steps = ntohl(steps);
	return steps;
}

- (BOOL)freeFallFromServiceData:(NSData *)serviceData
{
	uint8_t ff;
	[serviceData getBytes:&ff length:sizeof(uint8_t)];
	return ff;
}

- (void)getTapsFromServiceData:(NSData *)serviceData count:(uint8_t *)count direction:(uint8_t *)direction
{
	uint8_t c;
	uint8_t d;
	
	[[serviceData subdataWithRange:NSMakeRange(0, sizeof(uint8_t))] getBytes:&d length:sizeof(uint8_t)];
	[[serviceData subdataWithRange:NSMakeRange(1, sizeof(uint8_t))] getBytes:&c length:sizeof(uint8_t)];
	
	*count = c;
	*direction = d;
}

- (BOOL)calibrationFromServiceData:(NSData *)serviceData
{
	uint8_t cal;
	[serviceData getBytes:&cal length:sizeof(uint8_t)];
	return (cal == 3);
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
    DLog(DLogLevelDebug, @"BRDeviceDidConnect: %@", device);
	[self.passthroughDelegate BRDeviceDidConnect:device];
	
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
	[self.passthroughDelegate BRDeviceDidDisconnect:device];
	
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
	[self.passthroughDelegate BRDevice:device didFailConnectWithError:ioBTError];
	
#warning analize + report errors
	
	NSDictionary *userInfo = @{PLTDeviceNotificationKey: self,
							   PLTDeviceConnectionErrorNotificationKey: @(ioBTError)};
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceDidFailOpenConnectionNotification object:nil userInfo:userInfo];
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
#ifndef TERSE_LOGGING
    DLog(DLogLevelTrace, @"BRDevice: %@ didReceiveEvent: %@", device, event);
#endif
	[self.passthroughDelegate BRDevice:device didReceiveEvent:event];
	
	PLTInfoRequestType requestType = PLTInfoRequestTypeSubscription;
	NSDate  *timestamp = [NSDate date];
	PLTInfo *info = nil;
	NSMutableArray *subscribers = [NSMutableArray array];
	PLTService service = -1;
	
	if ([event isKindOfClass:[BRSubscribedServiceDataEvent class]]) {
		BRSubscribedServiceDataEvent *serviceDataEvent = (BRSubscribedServiceDataEvent *)event;
		uint16_t serviceID = serviceDataEvent.serviceID;
		NSData *serviceData = serviceDataEvent.serviceData;
		
		switch (serviceID) {
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Orientation: {
				service = PLTServiceOrientation;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				PLTQuaternion quaternion = [self quaternionFromServiceData:serviceData];
				if ([self checkQuaternion:quaternion]) {
					if (self.queryingOrientationForCalibration) {
						self.orientationCalibration = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:quaternion];
						self.queryingOrientationForCalibration = NO;
					}
					info = [[PLTOrientationTrackingInfo alloc] initWithRequestType:requestType
																		 timestamp:timestamp
																	   calibration:self.orientationCalibration
																		quaternion:quaternion];
				}
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Pedometer: {
				service = PLTServicePedometer;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				uint32_t steps = [self pedometerCountFromServiceData:serviceData];
				info = [[PLTPedometerInfo alloc] initWithRequestType:requestType
														   timestamp:timestamp
														 calibration:nil
#warning temporary cal
															   steps:steps - self.pedometerOffset];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_FreeFall: {
				service = PLTServiceFreeFall;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				BOOL isInFreeFall = [self freeFallFromServiceData:serviceData];
				info = [[PLTFreeFallInfo alloc] initWithRequestType:requestType
														  timestamp:timestamp
														calibration:nil
														   freeFall:isInFreeFall];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Taps: {
				service = PLTServiceTaps;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				uint8_t count;
				uint8_t direction;
				[self getTapsFromServiceData:serviceData count:&count direction:&direction];
				info = [[PLTTapsInfo alloc] initWithRequestType:requestType
													  timestamp:timestamp
													calibration:nil
													  direction:direction
														  count:count];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus: {
				service = PLTServiceGyroscopeCalibrationStatus;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				BOOL isCalibrated = [self calibrationFromServiceData:serviceData];
				info = [[PLTGyroscopeCalibrationInfo alloc] initWithRequestType:requestType
																	  timestamp:timestamp
																	calibration:nil
															  calibrationStatus:isCalibrated];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagnetometerCalibrationStatus: {
				service = PLTServiceMagnetometerCalibrationStatus;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				BOOL isCalibrated = [self calibrationFromServiceData:serviceData];
				info = [[PLTMagnetometerCalibrationInfo alloc] initWithRequestType:requestType
																		 timestamp:timestamp
																	   calibration:nil
																 calibrationStatus:isCalibrated];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration: {
				service = PLTServiceAcceleration;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				info = [[PLTAccelerationInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															calibration:nil
															serviceData:serviceData];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_AngularVelocity: {
				service = PLTServiceAngularVelocity;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				info = [[PLTAngularVelocityInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															   calibration:nil
															   serviceData:serviceData];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField: {
				service = PLTServiceMagnetism;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				info = [[PLTMagnetismInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															calibration:nil
															serviceData:serviceData];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Heading: {
				service = PLTServiceHeading;
				subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
				info = [[PLTHeadingInfo alloc] initWithRequestType:requestType
														 timestamp:timestamp
													   calibration:nil
													   serviceData:serviceData];
				break; }
		}
	}
	else if ([event isKindOfClass:[BRWearingStateChangedEvent class]]) {
		service = PLTServiceWearingState;
		BRWearingStateChangedEvent *e = (BRWearingStateChangedEvent *)event;
		info = [[PLTWearingStateInfo alloc] initWithRequestType:requestType
													  timestamp:timestamp
													calibration:nil
												   wearingState:e.worn];
		
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
		uint8_t connectionID = e.connectionId;
		
		// if temporarily turning on signal strength events, it can take several "unknown" distance events before a near/far value is generated.
		// wait until then to return distance query.
		if (e.nearFar != PLTProximityUnknown) {
			// check if we're waiting on a signal strength query
			PLTProximityInfo *queryInfo = nil;
			if (connectionID == self.remotePort) {
				if (self.waitingForRemoteSignalStrengthEvent) {
					self.remoteQuerySignalStrengthEvent = e;
					if (self.localQuerySignalStrengthEvent) {
						// we're got both.
						queryInfo = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
																   localProximity:self.localQuerySignalStrengthEvent.nearFar remoteProximity:self.remoteQuerySignalStrengthEvent.nearFar];
					}
				}
			}
			else {
				if (self.waitingForLocalSignalStrengthEvent) {
					self.localQuerySignalStrengthEvent = e;
					if (self.waitingForRemoteSignalStrengthEvent) {
						if (self.remoteQuerySignalStrengthEvent) {
							// we're got both.
							queryInfo = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
																	   localProximity:self.localQuerySignalStrengthEvent.nearFar remoteProximity:self.remoteQuerySignalStrengthEvent.nearFar];
						}
					}
					else {
						// not waiting on remote. we've got just the one.
						PLTProximity cachedRemoteProximity = PLTProximityUnknown;
						if (cachedInfo) {
							cachedRemoteProximity = cachedInfo.remoteProximity;
						}
						
						queryInfo = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
																   localProximity:self.localQuerySignalStrengthEvent.nearFar remoteProximity:cachedRemoteProximity];
					}
				}
			}
			
			if (queryInfo) {
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
		
		PLTProximity proximity = (PLTProximity)e.nearFar; // maps directly
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
	
//#warning BANGLE
//	else if ([event isKindOfClass:[BRSubscribedServiceDataEvent class]]) {
//		BRSubscribedServiceDataEvent *serviceDataEvent = (BRSubscribedServiceDataEvent *)event;
//		//NSLog(@"service: 0x%04X, characteristic: 0x%04X, data: %@", serviceDataEvent.serviceID, serviceDataEvent.characteristic, [serviceDataEvent.serviceData hexStringWithSpaceEvery:2]);
//		
//		Class class = nil;
//		service = serviceDataEvent.serviceID; // BR IDs map directly to PLTLabs IDs
//		subscribers = ((PLTSubscription *)self.subscriptions[@(service)]).subscribers;
//		
//		switch (serviceDataEvent.serviceID) {
//			case BRServiceIDSkinTemperature:
//				class = [PLTSkinTemperatureInfo class];
//				break;
//				
//			case BRServiceIDAmbientHumidity:
//				class = [PLTAmbientHumidityInfo class];
//				break;
//				
//			case BRServiceIDAmbientPressure:
//				class = [PLTAmbientPressureInfo class];
//				break;
//				
//			default:
//				break;
//		}
//		
//		if (class) {
//			info = [[class alloc] initWithRequestType:requestType
//											timestamp:timestamp
//										  calibration:nil
//										  serviceData:serviceDataEvent.serviceData];
//		}
//	}

	if (info) {
		self.cachedInfo[@(service)] = info;
	}
	
	if (subscribers) {
		for (id<PLTDeviceSubscriber> s in subscribers) {
			[s PLTDevice:self didUpdateInfo:info];
		}
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResult:(BRSettingResult *)result
{
#ifndef TERSE_LOGGING
    DLog(DLogLevelDebug, @"BRDevice: %@ didReceiveSettingResult: %@", device, result);
#endif
	[self.passthroughDelegate BRDevice:device didReceiveSettingResult:result];
	
	PLTInfoRequestType requestType = PLTInfoRequestTypeQuery;
	NSDate *timestamp = [NSDate date];
	PLTInfo *info = nil;
	int service = -1; // not PLTService because it must be signed
	NSArray *subscribers = nil;
	
	if ([result isKindOfClass:[BRQueryServicesDataSettingResult class]]) {
		BRQueryServicesDataSettingResult *serviceDataResult = (BRQueryServicesDataSettingResult *)result;
		uint16_t serviceID = serviceDataResult.serviceID;
		NSData *serviceData = serviceDataResult.servicedata;
		
		switch (serviceID) {
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Orientation: {
				PLTQuaternion quaternion = [self quaternionFromServiceData:serviceData];
				if ([self checkQuaternion:quaternion]) {
					if (self.queryingOrientationForCalibration) {
						self.orientationCalibration = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:quaternion];
						self.queryingOrientationForCalibration = NO;
					}
					else {
						service = PLTServiceOrientation;
						info = [[PLTOrientationTrackingInfo alloc] initWithRequestType:requestType
																			 timestamp:timestamp
																		   calibration:self.orientationCalibration
																			quaternion:quaternion];
					}
				}
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Pedometer: {
				service = PLTServicePedometer;
				uint32_t steps = [self pedometerCountFromServiceData:serviceData];
				info = [[PLTPedometerInfo alloc] initWithRequestType:requestType
														   timestamp:timestamp
														 calibration:nil
#warning temporary cal
															   steps:steps - self.pedometerOffset];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_FreeFall: {
				service = PLTServiceFreeFall;
				BOOL isInFreeFall = [self freeFallFromServiceData:serviceData];
				info = [[PLTFreeFallInfo alloc] initWithRequestType:requestType
														  timestamp:timestamp
														calibration:nil
														   freeFall:isInFreeFall];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Taps: {
				service = PLTServiceTaps;
				uint8_t count;
				uint8_t direction;
				[self getTapsFromServiceData:serviceData count:&count direction:&direction];
				info = [[PLTTapsInfo alloc] initWithRequestType:requestType
													  timestamp:timestamp
													calibration:nil
													  direction:direction
														  count:count];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus: {
				service = PLTServiceGyroscopeCalibrationStatus;
				BOOL isCalibrated = [self calibrationFromServiceData:serviceData];
				info = [[PLTGyroscopeCalibrationInfo alloc] initWithRequestType:requestType
																	  timestamp:timestamp
																	calibration:nil
															  calibrationStatus:isCalibrated];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagnetometerCalibrationStatus: {
				service = PLTServiceMagnetometerCalibrationStatus;
				BOOL isCalibrated = [self calibrationFromServiceData:serviceData];
				info = [[PLTMagnetometerCalibrationInfo alloc] initWithRequestType:requestType
																		 timestamp:timestamp
																	   calibration:nil
																 calibrationStatus:isCalibrated];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration: {
				service = PLTServiceAcceleration;
				info = [[PLTAccelerationInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															calibration:nil
															serviceData:serviceData];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_AngularVelocity: {
				service = PLTServiceAngularVelocity;
				info = [[PLTAngularVelocityInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															   calibration:nil
															   serviceData:serviceData];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField: {
				service = PLTServiceMagnetism;
				info = [[PLTMagnetismInfo alloc] initWithRequestType:requestType
															  timestamp:timestamp
															calibration:nil
															serviceData:serviceData];
				break; }
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Heading: {
				service = PLTServiceHeading;
				info = [[PLTHeadingInfo alloc] initWithRequestType:requestType
														 timestamp:timestamp
													   calibration:nil
													   serviceData:serviceData];
				break; }
		}
	}
	else if ([result isKindOfClass:[BRWearingStateSettingResult class]]) {
		BRWearingStateSettingResult *r = (BRWearingStateSettingResult *)result;
		service = PLTServiceWearingState;
		info = [[PLTWearingStateInfo alloc] initWithRequestType:requestType
													  timestamp:timestamp
													calibration:nil
												   wearingState:r.worn];
		
		if (self.waitingForWearingStatePrimer) {
			self.waitingForWearingStatePrimer = NO;
			
			info.requestType = PLTInfoRequestTypeCached;
			self.cachedInfo[@(PLTServiceWearingState)] = info;
			info = nil; // probably not necessary since querySubscribers wouldn't have any wearing state listeners...
		}
	}
	else if ([result isKindOfClass:[BRCurrentSignalStrengthSettingResult class]]) {
		BRCurrentSignalStrengthSettingResult *r = (BRCurrentSignalStrengthSettingResult *)result;
		service = PLTServiceProximity;
		
		PLTProximityInfo *cachedInfo = (PLTProximityInfo *)self.cachedInfo[@(service)];
		uint8_t connectionID = r.connectionId;
		
		// check if we're waiting on a signal strength query
		if (connectionID == self.remotePort) {
			if (self.waitingForRemoteSignalStrengthSettingResult) {
				self.remoteQuerySignalStrengthResult = r;
				if (self.localQuerySignalStrengthResult) {
					// we're got both.
					info = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
															   localProximity:self.localQuerySignalStrengthEvent.nearFar remoteProximity:self.remoteQuerySignalStrengthEvent.nearFar];
				}
			}
		}
		else {
			if (self.waitingForLocalSignalStrengthSettingResult) {
				self.localQuerySignalStrengthResult = r;
				if (self.waitingForRemoteSignalStrengthSettingResult) {
					if (self.remoteQuerySignalStrengthResult) {
						// we're got both.
						info = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
															  localProximity:self.localQuerySignalStrengthEvent.nearFar remoteProximity:self.remoteQuerySignalStrengthEvent.nearFar];
					}
				}
				else {
					// not waiting on remote. we've got just the one.
					PLTProximity cachedRemoteProximity = PLTProximityUnknown;
					if (cachedInfo) {
						cachedRemoteProximity = cachedInfo.remoteProximity;
					}
					
					info = [[PLTProximityInfo alloc] initWithRequestType:PLTInfoRequestTypeQuery timestamp:timestamp calibration:nil
														  localProximity:self.localQuerySignalStrengthEvent.nearFar remoteProximity:cachedRemoteProximity];
				}
			}
		}
		
		if (info) {
			self.waitingForRemoteSignalStrengthSettingResult = NO;
			self.waitingForLocalSignalStrengthSettingResult = NO;
			self.localQuerySignalStrengthResult = nil;
			self.remoteQuerySignalStrengthResult = nil;
		}
	}
	else if ([result isKindOfClass:[BRGetDeviceInfoSettingResult class]]) {
		[self didGetDeviceInfo:(BRGetDeviceInfoSettingResult *)result];
    }
	else if ([result isKindOfClass:[BRGenesGUIDSettingResult class]]) {
		[self didGetGUID:(BRGenesGUIDSettingResult *)result];
	}
	else if ([result isKindOfClass:[BRProductNameSettingResult class]]) {
		[self didGetProductName:(BRProductNameSettingResult *)result];
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
	[self.passthroughDelegate BRDevice:device didRaiseSettingException:exception];
	
#warning Use BRDeviceUtilities to get deckard ID
	//	uint16_t exceptionID = exception.deckardID;
	//	if (exceptionID == 0x0A1E) {
	//		if (!self.isConnectionOpen) { // really we should have states for all steps in the handshake... maybe add this later...
	//			[self didGetGUID:nil];
	//		}
	//	}
}

- (void)BRDevice:(BRDevice *)device didRaiseCommandException:(BRException *)exception
{
	DLog(DLogLevelError, @"BRDevice: %@ didRaiseCommandException: %@", device, exception);
	[self.passthroughDelegate BRDevice:device didRaiseCommandException:exception];
}

- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice
{
	DLog(DLogLevelDebug, @"BRDevice: %@ didFindRemoteDevice: %@", device, remoteDevice);
	[self.passthroughDelegate BRDevice:device didFindRemoteDevice:remoteDevice];
	
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
	[self.passthroughDelegate BRDevice:device willSendData:data];
	
	NSString *hexString = BRDeviceHexStringFromData(data, 2);
    DLog(DLogLevelTrace, @"--> %@", hexString);
	
	NSDictionary *userInfo = @{PLTDeviceDataNotificationKey: data};
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceWillSendDataNotification object:nil userInfo:userInfo];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	[self.passthroughDelegate BRDevice:device didReceiveData:data];
	
    NSString *hexString = BRDeviceHexStringFromData(data, 2);
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
			self, self.address, self.model, self.name, self.serialNumber, self.hardwareVersion, self.firmwareVersion, BRDeviceDescriptionFromArrayOfShortIntegers(self.supportedServices), (self.isConnectionOpen ? @"YES" : @"NO")];	
#endif
#ifdef TARGET_IOS
	return [NSString stringWithFormat:@"<PLTDevice: %p> model=%@, name=%@, serialNumber=%@, hardwareVersion=%@, firmwareVersion=%@, supportedServices=%@, isConnectionOpen=%@",
			self, self.model, self.name, self.serialNumber, self.hardwareVersion, self.firmwareVersion, BRDeviceDescriptionFromArrayOfShortIntegers(self.supportedServices), (self.isConnectionOpen ? @"YES" : @"NO")];
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
	return [NSString stringWithFormat:@"<PLTInternalSubscription %p> service=0x%04X, mode=0x%02X, period=0x%04X, subscribers=%@",
			self, self.service, self.mode, self.period, self.subscribers];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTSubscription %p> service=0x%04X, mode=0x%02X, period=0x%04X",
			self, self.service, self.mode, self.period];
}

@end

