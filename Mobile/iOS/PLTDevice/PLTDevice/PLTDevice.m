//
//  PLTDevice.m
//  PLTDevice
//
//  Created by Davis, Morgan on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
#import "PLTDeviceWatcher.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <UIKit/UIKit.h>
#import "PLTInfo_Internal.h"
#import "PLTWearingStateInfo_Internal.h"
#import "PLTProximityInfo_Internal.h"
#import "PLTOrientationTrackingInfo_Internal.h"
#import "PLTTapsInfo_Internal.h"
#import "PLTPedometerInfo_Internal.h"
#import "PLTFreeFallInfo_Internal.h"
#import "PLTMagnetometerCalibrationInfo_Internal.h"
#import "PLTGyroscopeCalibrationInfo_Internal.h"


#define TICKER_RATE											20.0 // Hz


NSString *const PLTDeviceNewDeviceAvailableNotification =	@"PLTDeviceNewDeviceAvailableNotification";
NSString *const PLTDeviceNewDeviceNotificationKey =			@"PLTDeviceNewDeviceNotificationKey";

NSString *const PLTDeviceErrorDomain =						@"com.plantronics.PLTDevice";

NSString *const PLTSubscriptionKeyService =					@"service";
NSString *const PLTSubscriptionKeyMode =					@"mode";
NSString *const PLTSubscriptionKeyPeriod =					@"period";
NSString *const PLTSubscriptionKeyLastUpdateDate =			@"lastUpdateDate";
NSString *const PLTSubscriptionKeyLastUpdateInfo =			@"lastUpdateInfo";

NSString *const PLTQueryObserverKeyObserver =				@"observer";
NSString *const PLTQueryObserverKeyService =				@"service";


typedef NS_ENUM(NSInteger, PLTService_Internal) {
	PLTServiceVersions = 0x0008
};


@interface PLTDevice() <NSStreamDelegate>

- (void)closeConnection:(BOOL)notifyClose;
- (void)didGetNewPacket:(NSData *)packetData;
- (BOOL)getWearingStateInfo:(PLTWearingStateInfo **)wearingStateInfo
			  proximityInfo:(PLTProximityInfo **)proximityInfo
	orientationTrackingInfo:(PLTOrientationTrackingInfo **)orientationTrackingInfo
				   tapsInfo:(PLTTapsInfo **)tapsInfo
			  pedometerInfo:(PLTPedometerInfo **)pedometerInfo
			   freeFallInfo:(PLTFreeFallInfo **)freeFallInfo
magnetometerCalibrationInfo:(PLTMagnetometerCalibrationInfo **)magnetometerCalibrationInfo
   gyroscapeCalibrationInfo:(PLTGyroscopeCalibrationInfo **)gyroscopeCalibrationInfo
			 fwMajorVersion:(NSNumber **)fwMajorVersion
			 fwMinorVersion:(NSNumber **)fwMinorVersion
			 fromPacketData:(NSData *)packetData
				requestType:(PLTInfoRequestType)requestType
				  timestamp:(NSDate *)timestamp;
- (void)didGetNewWearingStateInfo:(PLTWearingStateInfo *)wearingStateInfo
					proximityInfo:(PLTProximityInfo *)proximityInfo
		  orientationTrackingInfo:(PLTOrientationTrackingInfo *)orientationTrackingInfo
						 tapsInfo:(PLTTapsInfo *)tapsInfo
					pedometerInfo:(PLTPedometerInfo *)pedometerInfo
					 freeFallInfo:(PLTFreeFallInfo *)freeFallInfo
	  magnetometerCalibrationInfo:(PLTMagnetometerCalibrationInfo *)magnetometerCalibrationInfo
		 gyroscapeCalibrationInfo:(PLTGyroscopeCalibrationInfo *)gyroscopeCalibrationInfo;
- (void)checkTicker;
- (void)ticker:(NSTimer *)aTimer;
- (BOOL)versionsCompatible;

@property(nonatomic, readwrite)			BOOL								isConnectionOpen;
@property(nonatomic, readwrite, strong)	NSString							*model;
@property(nonatomic, readwrite, strong)	NSString							*name;
@property(nonatomic, readwrite, strong)	NSString							*serialNumber;
@property(nonatomic, readwrite)			NSUInteger							fwMajorVersion;
@property(nonatomic, readwrite)			NSUInteger							fwMinorVersion;
@property(nonatomic, retain)			EASession							*session;
@property(nonatomic)					BOOL								didGetVersionInfo;
@property(nonatomic)					BOOL								didNotifyOfConnectionOpen;
@property(nonatomic)					BOOL								didNotifyOfConnectionClosed;
@property(nonatomic, retain)			PLTWearingStateInfo					*latestWearingStateInfo;
@property(nonatomic, retain)			PLTProximityInfo					*latestProximityInfo;
@property(nonatomic, retain)			PLTOrientationTrackingInfo			*latestOrientationTrackingInfo;
@property(nonatomic, retain)			PLTTapsInfo							*latestTapsInfo;
@property(nonatomic, retain)			PLTPedometerInfo					*latestPedometerInfo;
@property(nonatomic, retain)			PLTFreeFallInfo						*latestFreeFallInfo;
@property(nonatomic, retain)			PLTMagnetometerCalibrationInfo		*latestMagnetometerCalibrationInfo;
@property(nonatomic, retain)			PLTGyroscopeCalibrationInfo			*latestGyroscopeCalibrationInfo;
@property(nonatomic, retain)			NSMutableDictionary					*subscribers;
@property(nonatomic, retain)			NSTimer								*ticker;
@property(nonatomic, retain)			NSMutableArray						*queryObservers;
@property(nonatomic, retain)			PLTOrientationTrackingCalibration	*orientationTrackingCalibration;
@property(nonatomic)					NSUInteger							pedometerOffset;
@property(nonatomic)					BOOL								didGetFreeFallUp;
@property(nonatomic)					BOOL								didGetFreeFallDown;
@property(nonatomic)					BOOL								didGetTapsUp;
@property(nonatomic)					BOOL								didGetTapsDown;

@end


@implementation PLTDevice

@dynamic supportedServices;

- (NSArray *)supportedServices
{
	// hard-coded for first revision
	
	return @[@(PLTServiceProximity),
			 @(PLTServiceWearingState),
			 @(PLTServiceOrientationTracking),
			 @(PLTServicePedometer),
			 @(PLTServiceFreeFall),
			 @(PLTServiceTaps),
			 @(PLTServiceMagnetometerCalStatus),
			 @(PLTServiceGyroscopeCalibrationStatus)];
}

#pragma mark - Public

+ (NSArray *)availableDevices
{
	return [[PLTDeviceWatcher sharedWatcher] devices];
}

- (void)openConnection
{
	NSLog(@"openConnection (%@)", self.accessory);
	
	if (!self.session) {
		// create data session if we found a matching accessory
		if (self.accessory) {
			NSLog(@"Attempting to create data session with accessory %@", [self.accessory name]);
			
			self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol:PLTDeviceProtocolString];
			if (self.session) {
				NSLog(@"Created EA session: %@", self.session);
				
				// reset state
				self.didGetVersionInfo = NO;
				self.didGetTapsUp = NO;
				self.didGetTapsDown = YES;
				self.didGetFreeFallUp = NO;
				self.didGetFreeFallDown = NO;
				
				// open input and output streams
				[[self.session inputStream] setDelegate:self];
				[[self.session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
				[[self.session inputStream] open];
				[[self.session outputStream] setDelegate:self];
				[[self.session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
				[[self.session outputStream] open];
				
				// wait for version info to come through to set isConnectionOpen = YES and notify
			}
			else {
				NSLog(@"Failed to create EA session.");
				NSError *error = [NSError errorWithDomain:PLTDeviceErrorDomain
													 code:PLTDeviceErrorCodeFailedToCreateDataSession
												 userInfo:@{NSLocalizedDescriptionKey : @"Failed to create External Accessory session."}];
				[self.connectionDelegate PLTDevice:self didFailToOpenConnection:error];
			}
		}
		else {
			NSLog(@"No accessory accociated!");
			NSError *error = [NSError errorWithDomain:PLTDeviceErrorDomain
												 code:PLTDeviceErrorCodeNoAccessoryAssociated
											 userInfo:@{NSLocalizedDescriptionKey : @"No create External Accessory associated."}];
			[self.connectionDelegate PLTDevice:self didFailToOpenConnection:error];
		}
	}
	else {
		NSLog(@"Data session already active.");
		NSError *error = [NSError errorWithDomain:PLTDeviceErrorDomain
											 code:PLTDeviceErrorCodeConnectionAlreadyOpen
										 userInfo:@{NSLocalizedDescriptionKey : @"External Accessory data session already open."}];
		[self.connectionDelegate PLTDevice:self didFailToOpenConnection:error];
	}
}

- (void)closeConnection
{
	[self closeConnection:YES];
}

- (void)setConfiguration:(PLTConfiguration *)aConfiguration forService:(PLTService)theService
{
	
}

- (PLTConfiguration *)configurationForService:(PLTService)theService
{
	return nil;
}

- (void)setCalibration:(PLTCalibration *)aCalibration forService:(PLTService)theService
{
	switch (theService) {
		case PLTServiceOrientationTracking: {
			// set the reference quaternion
			PLTOrientationTrackingCalibration *cal = (PLTOrientationTrackingCalibration *)aCalibration;
			if (!cal) {
				cal = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:self.latestOrientationTrackingInfo.rawQuaternion];
			}
			self.orientationTrackingCalibration = cal;
			break; }
		case PLTServicePedometer:
			// set pedometer offset
			self.pedometerOffset = self.latestPedometerInfo.steps;
			break;
		default:
			break;
	}
}

- (PLTCalibration *)calibrationForService:(PLTService)theService
{
	if (theService == PLTServiceOrientationTracking) {
		return self.orientationTrackingCalibration;
	}
	return nil;
}

- (NSError *)subscribe:(id <PLTDeviceInfoObserver>)aSubscriber toService:(PLTService)service withMode:(PLTSubscriptionMode)mode minPeriod:(NSUInteger)minPeriod
{
	NSLog(@"subscribe: %@ toService: %d withMode: %d minPeriod: %d", aSubscriber, service, mode, minPeriod);
	
	if (!aSubscriber) {
		NSDictionary *info = @{ NSLocalizedDescriptionKey : @"Subscriber is nil.", };
		return [NSError errorWithDomain:PLTDeviceErrorDomain code:PLTDeviceErrorInvalidArgument userInfo:info];
	}
	else if (![self.supportedServices containsObject:@(service)]) {
		NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Invalid service: %d.", service] };
		return [NSError errorWithDomain:PLTDeviceErrorDomain code:PLTDeviceErrorInvalidService userInfo:info];
	}
	else if (mode == PLTSubscriptionModePeriodic) {
		if ((service==PLTServiceTaps) || (service==PLTServiceFreeFall)) {
			NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Periodic subscription is not supported by service %d.", service] };
			return [NSError errorWithDomain:PLTDeviceErrorDomain code:PLTDeviceErrorUnsupportedMode userInfo:info];
		}
	}
	else if (mode > PLTSubscriptionModePeriodic) {
		NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Invalid mode: %d", service], };
		return [NSError errorWithDomain:PLTDeviceErrorDomain code:PLTDeviceErrorInvalidMode userInfo:info];
	}
	
	// look up or add aSubscriber
	NSMutableArray *subscriptions = self.subscribers[[NSValue valueWithPointer:(__bridge const void *)(aSubscriber)]];
	if (!subscriptions) {
		subscriptions = [NSMutableArray array];
		self.subscribers[[NSValue valueWithPointer:(__bridge const void *)(aSubscriber)]] = subscriptions;
		//NSLog(@"Created empty subscription list.");
	}
	else {
		//NSLog(@"Found subscriptions: %@", subscriptions);
	}
	
	// look up or add a subscribed service
	NSMutableDictionary *subscription = nil;
	int subscriptionIndex = -1;
	for (int i=0; i<[subscriptions count]; i++) {
		NSMutableDictionary *s = subscriptions[i];
		if ([s[PLTSubscriptionKeyService] isEqualToNumber:@(service)]) {
			subscription = s;
			subscriptionIndex = i;
			//NSLog(@"Found subscription (index %d): %@", subscriptionIndex, subscription);
			break;
		}
	}
	if (!subscription) {
		subscription = [NSMutableDictionary dictionary];
		//NSLog(@"Created new subscription.");
	}
	
	subscription[PLTSubscriptionKeyService] = @(service);
	subscription[PLTSubscriptionKeyMode] = @(mode);
	subscription[PLTSubscriptionKeyPeriod] = @(minPeriod);
	
	//NSLog(@"New subscription: %@", subscription);
	
	if (subscriptionIndex >= 0) {
		[subscriptions replaceObjectAtIndex:subscriptionIndex withObject:subscription];
		//NSLog(@"Replaced subscription at index %d with new subscription.", subscriptionIndex);
	}
	else {
		[subscriptions addObject:subscription];
		//NSLog(@"Added new subscription.");
	}
	
	[self checkTicker];
	
	return nil;
}

- (void)unsubscribe:(id <PLTDeviceInfoObserver>)aSubscriber fromService:(PLTService)theService
{
	NSLog(@"unsubscribe: %@ fromService: %d", aSubscriber, theService);
	
	// look up aSubscriber
	NSMutableArray *subscriptions = self.subscribers[[NSValue valueWithPointer:(__bridge const void *)(aSubscriber)]];
	if (subscriptions) {
		// look up and remove the subscription
	}
	
	NSMutableIndexSet *removalIndexes = [NSMutableIndexSet indexSet];
	for (int i=0; i<[subscriptions count]; i++) {
		NSMutableDictionary *s = subscriptions[i];
		if ([s[PLTSubscriptionKeyService] isEqualToNumber:@(theService)]) {
			[removalIndexes addIndex:i];
		}
	}
	[subscriptions removeObjectsAtIndexes:removalIndexes];
	self.subscribers[[NSValue valueWithPointer:(__bridge const void *)(aSubscriber)]] = subscriptions;
}

- (void)unsubscribeFromAll:(id <PLTDeviceInfoObserver>)aSubscriber
{
	NSArray *services = [self supportedServices];
	for (NSNumber *service in services) {
		[self unsubscribe:aSubscriber fromService:[service unsignedIntegerValue]];
	}
}

- (NSArray *)subscriptions
{
	NSLog(@"*** Not implemented. ***");
	return nil;
}

- (PLTInfo *)cachedInfoForService:(PLTService)aService
{
	switch (aService) {
		case PLTServiceProximity:
			return self.latestProximityInfo;
			break;
		case PLTServiceWearingState:
			return self.latestWearingStateInfo;
			break;
		case PLTServiceOrientationTracking:
			return self.latestOrientationTrackingInfo;
			break;
		case PLTServicePedometer:
			return self.latestPedometerInfo;
			break;
		case PLTServiceFreeFall:
			return self.latestFreeFallInfo;
			break;
		case PLTServiceTaps:
			return self.latestTapsInfo;
			break;
		case PLTServiceMagnetometerCalStatus:
			return self.latestMagnetometerCalibrationInfo;
			break;
		case PLTServiceGyroscopeCalibrationStatus:
			return self.latestGyroscopeCalibrationInfo;
			break;
	}
	return nil;
}

- (void)queryInfo:(id <PLTDeviceInfoObserver>)theObserver forService:(PLTService)aService;
{
	// add theObserver to the list of waiting observers for service info and then notify the observers when the info comes in
	
	if (!self.queryObservers) {
		self.queryObservers = [NSMutableArray array];
	}
	
	BOOL contains = NO;
	for (NSDictionary *queryObserver in self.queryObservers) {
		
		id observer = queryObserver[PLTQueryObserverKeyObserver];
		if (theObserver == observer) {
			if ([queryObserver[PLTQueryObserverKeyService] isEqualToNumber:@(aService)]) {
				contains = YES;
				break;
			}
		}
	}
	
	if (!contains) {
		NSDictionary *queryObserver = @{ PLTQueryObserverKeyObserver : theObserver, PLTQueryObserverKeyService : @(aService) };
		[self.queryObservers addObject:queryObserver];
	}
}

#pragma mark - API Internal

- (PLTDevice *)initWithAccessory:(EAAccessory *)anAccessory
{
	if (self = [super init]) {
		
		self.accessory = anAccessory;
		self.model = self.accessory.modelNumber;
		self.name = self.accessory.name;
		self.serialNumber = self.accessory.serialNumber;
		self.subscribers = [NSMutableDictionary dictionary];
        
		self.orientationTrackingCalibration = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:(PLTQuaternion){ 1, 0, 0, 0 }];
    }
	
    return self;
}

#pragma mark - Private

- (void)closeConnection:(BOOL)notifyClose
{
	NSLog(@"closeConnection (%@)", self.accessory);

	if (self.session) {
		[[self.session inputStream] close];
        [[self.session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.session inputStream] setDelegate:nil];
        [[self.session outputStream] close];
        [[self.session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.session outputStream] setDelegate:nil];
		
		
		// new in 1.0.1
		self.subscribers = [NSMutableDictionary dictionary];
		self.queryObservers = nil;
		
        
        self.session = nil;
		self.isConnectionOpen = NO;
		
		if (notifyClose) {
			[self.connectionDelegate PLTDeviceDidCloseConnection:self];
		}
	}
}

- (void)didGetNewPacket:(NSData *)packetData
{
	PLTWearingStateInfo *wearingStateInfo;
	PLTProximityInfo *proximityInfo;
	PLTOrientationTrackingInfo *orientationTrackingInfo;
	PLTTapsInfo *tapsInfo;
	PLTPedometerInfo *pedometerInfo;
	PLTFreeFallInfo *freeFallInfo;
	PLTMagnetometerCalibrationInfo *magnetometerCalibrationInfo;
	PLTGyroscopeCalibrationInfo *gyroscopeCalibrationInfo;
	NSNumber *fwMajorVersion;
	NSNumber *fwMinorVersion;

	if (![self getWearingStateInfo:&wearingStateInfo
					 proximityInfo:&proximityInfo
		   orientationTrackingInfo:&orientationTrackingInfo
						  tapsInfo:&tapsInfo
					 pedometerInfo:&pedometerInfo
					  freeFallInfo:&freeFallInfo
	   magnetometerCalibrationInfo:&magnetometerCalibrationInfo
		  gyroscapeCalibrationInfo:&gyroscopeCalibrationInfo
					fwMajorVersion:&fwMajorVersion
					fwMinorVersion:&fwMinorVersion
					fromPacketData:packetData
					   requestType:PLTInfoRequestTypeSubscription
						 timestamp:[NSDate date]]) {
		
		NSLog(@"Error parsing packet data.");
	}
	else {
		if (!self.didGetVersionInfo) {
			//NSLog(@"Got version info.");
			
			self.fwMajorVersion = fwMajorVersion.unsignedIntegerValue;
			self.fwMinorVersion = fwMinorVersion.unsignedIntegerValue;
			self.didGetVersionInfo = YES;
			
			BOOL versionsOK = [self versionsCompatible];
			if (!versionsOK) {
				[self closeConnection:NO];
				self.isConnectionOpen = NO;
				NSString *description = [NSString stringWithFormat:@"API version %.1f is incompatible with device version %u.%u", PLT_API_VERSION, self.fwMajorVersion, self.fwMinorVersion];
				NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description };
				NSError *error = [[NSError alloc] initWithDomain:PLTDeviceErrorDomain code:PLTDeviceErrorIncompatibleVersions userInfo:userInfo];
				[self.connectionDelegate PLTDevice:self didFailToOpenConnection:error];
			}
			else {
				self.isConnectionOpen = YES;
				// notify delegate of connection open
				[self.connectionDelegate PLTDeviceDidOpenConnection:self];
			}
		}
		
		[self didGetNewWearingStateInfo:wearingStateInfo
						  proximityInfo:proximityInfo
				orientationTrackingInfo:orientationTrackingInfo
							   tapsInfo:tapsInfo
						  pedometerInfo:pedometerInfo
						   freeFallInfo:freeFallInfo
			magnetometerCalibrationInfo:magnetometerCalibrationInfo
			   gyroscapeCalibrationInfo:gyroscopeCalibrationInfo];
	}
}

- (BOOL)getWearingStateInfo:(PLTWearingStateInfo **)wearingStateInfo
			  proximityInfo:(PLTProximityInfo **)proximityInfo
	orientationTrackingInfo:(PLTOrientationTrackingInfo **)orientationTrackingInfo
				   tapsInfo:(PLTTapsInfo **)tapsInfo
			  pedometerInfo:(PLTPedometerInfo **)pedometerInfo
			   freeFallInfo:(PLTFreeFallInfo **)freeFallInfo
magnetometerCalibrationInfo:(PLTMagnetometerCalibrationInfo **)magnetometerCalibrationInfo
   gyroscapeCalibrationInfo:(PLTGyroscopeCalibrationInfo **)gyroscopeCalibrationInfo
			 fwMajorVersion:(NSNumber **)fwMajorVersion
			 fwMinorVersion:(NSNumber **)fwMinorVersion
			 fromPacketData:(NSData *)packetData
				requestType:(PLTInfoRequestType)requestType
				  timestamp:(NSDate *)timestamp

{
	NSUInteger len = [packetData length];
    uint8_t *buf = malloc(len);
    [packetData getBytes:buf length:len];
    
    if (!(buf[0] == 0x24) && !(buf[21] == 0xd) && !(buf[22] == 0xa)) {
        NSLog(@"*** Badly formed or misaligned packet. Discarding. ***");
        return NO;
    }
    
	//	NSMutableString *hexStr = [NSMutableString stringWithCapacity:len*2];
	//	for (int i = 0; i < len; i++) [hexStr appendFormat:@"%02x", buf[i]];
	//	NSLog(@"Raw packet:\t\t\t%@",hexStr);
    
    uint8_t quatdata[16];
    quatdata[0] = 0;
    quatdata[1] = 0;
    quatdata[2] = buf[3];
    quatdata[3] = buf[4];
    quatdata[4] = 0;
    quatdata[5] = 0;
    quatdata[6] = buf[7];
    quatdata[7] = buf[8];
    quatdata[8] = 0;
    quatdata[9] = 0;
    quatdata[10] = buf[11];
    quatdata[11] = buf[12];
    quatdata[12] = 0;
    quatdata[13] = 0;
    quatdata[14] = buf[15];
    quatdata[15] = buf[16];
    
    long quatn[4];
    double quat[4];
    
    uint32_t temp;
    temp = (((uint32_t)quatdata[2]) << 8) + ((uint32_t)quatdata[3]);
    quatn[0] = (long)temp;
    temp = (((uint32_t)quatdata[6]) << 8) + ((uint32_t)quatdata[7]);
    quatn[1] = (long)temp;
    temp = (((uint32_t)quatdata[10]) << 8) + ((uint32_t)quatdata[11]);
    quatn[2] = (long)temp;
    temp = (((uint32_t)quatdata[14]) << 8) + ((uint32_t)quatdata[15]);
    quatn[3] = (long)temp;
    
	*wearingStateInfo = [[PLTWearingStateInfo alloc] initWithRequestType:requestType timestamp:timestamp wearingState:[@(buf[5]) boolValue]];
	PLTProximity mobileProximity = buf[2] >> 4;
	PLTProximity pcProximity = ((uint8_t)((uint8_t)buf[2] << 4)) >> 4;
	*proximityInfo = [[PLTProximityInfo alloc] initWithRequestType:requestType timestamp:timestamp pcProximity:pcProximity mobileProximity:mobileProximity];
    *freeFallInfo = [[PLTFreeFallInfo alloc] initWithRequestType:requestType timestamp:timestamp freeFall:buf[6]];
    temp = (((uint16_t)buf[9]) << 8) + ((uint16_t)buf[10]);
	*pedometerInfo = [[PLTPedometerInfo alloc] initWithRequestType:requestType timestamp:timestamp steps:(uint16_t)temp];
	*tapsInfo = [[PLTTapsInfo alloc] initWithRequestType:requestType timestamp:timestamp taps:buf[14] direction:buf[13]];
	*magnetometerCalibrationInfo = [[PLTMagnetometerCalibrationInfo alloc] initWithRequestType:requestType timestamp:timestamp calibrationStatus:buf[17]];
	*gyroscopeCalibrationInfo = [[PLTGyroscopeCalibrationInfo alloc] initWithRequestType:requestType timestamp:timestamp  calibrationStatus:buf[18]];
    *fwMajorVersion = @(buf[19]);
	*fwMinorVersion = @(buf[20]);
    
    // process the quaternion
    for (int i = 0; i < 4; i++) {
        if (quatn[i] > 32767) {
            quatn[i] -= 65536;
        }
        quat[i] = ((double)quatn[i]) / 16384.0f;// 32768.0f
	}
	
    for (int i=0; i<3; i++) {
        if (quat[i] > 1.0001f) {
            NSLog(@"Bad quaternion! %f, %f, %f, %f",quat[0],quat[1],quat[2],quat[3]);
            *orientationTrackingInfo = nil;
			return NO;
        }
    }
	
    printf(".");
	
	PLTQuaternion quaternion = { quat[0], quat[1], quat[2], quat[3] };
	*orientationTrackingInfo = [[PLTOrientationTrackingInfo alloc] initWithRequestType:requestType
																			 timestamp:timestamp
																		 rawQuaternion:quaternion
																   referenceQuaternion:self.orientationTrackingCalibration.referenceQuaternion];
	
	return YES;
}

- (void)didGetNewWearingStateInfo:(PLTWearingStateInfo *)wearingStateInfo
					proximityInfo:(PLTProximityInfo *)proximityInfo
		  orientationTrackingInfo:(PLTOrientationTrackingInfo *)orientationTrackingInfo
						 tapsInfo:(PLTTapsInfo *)tapsInfo
					pedometerInfo:(PLTPedometerInfo *)pedometerInfo
					 freeFallInfo:(PLTFreeFallInfo *)freeFallInfo
	  magnetometerCalibrationInfo:(PLTMagnetometerCalibrationInfo *)magnetometerCalibrationInfo
		 gyroscapeCalibrationInfo:(PLTGyroscopeCalibrationInfo *)gyroscopeCalibrationInfo
{
//	NSLog(@"\n---------------------------------------------");
//	NSLog(@"wearingStateInfo: %@", wearingStateInfo);
//	NSLog(@"proximityInfo: %@", proximityInfo);
//	NSLog(@"orientationTrackingInfo: %@", orientationTrackingInfo);
//	NSLog(@"tapsInfo: %@", tapsInfo);
//	NSLog(@"pedometerInfo: %@", pedometerInfo);
//	NSLog(@"freeFallInfo: %@", freeFallInfo);
//	NSLog(@"magnetometerCalibrationInfo: %@", magnetometerCalibrationInfo);
//	NSLog(@"gyroscopeCalibrationInfo: %@", gyroscopeCalibrationInfo);
		
	self.latestWearingStateInfo = wearingStateInfo;
	self.latestProximityInfo = proximityInfo;
	self.latestOrientationTrackingInfo = orientationTrackingInfo;
	
//	if (!self.latestTapsInfo && tapsInfo.taps==0) {
//		self.latestTapsInfo = [[PLTTapsInfo alloc] initWithRequestType:0 timestamp:nil taps:0 direction:0];
//	}
//	else if (tapsInfo.taps != 0) {
//		self.latestTapsInfo = tapsInfo;
//	}

	BOOL notifyTapsChanged = NO;
	PLTTapsInfo *lastTapsInfo = self.latestTapsInfo;
	self.latestTapsInfo = tapsInfo;
	if (tapsInfo.taps != 0) {
		if ((!self.didGetTapsUp && ![tapsInfo isEqual:lastTapsInfo]) || self.didGetTapsDown) {
			self.didGetTapsUp = YES;
			self.didGetTapsDown = NO;
			notifyTapsChanged = YES;
		}
		else {
			self.latestTapsInfo = [[PLTTapsInfo alloc] initWithRequestType:tapsInfo.requestType timestamp:tapsInfo.timestamp taps:0 direction:0];
		}
	}
	else {
		self.latestTapsInfo = [[PLTTapsInfo alloc] initWithRequestType:tapsInfo.requestType timestamp:tapsInfo.timestamp taps:0 direction:0];
		self.didGetTapsUp = NO;
		self.didGetTapsDown = YES;
	}

	// apply pedometer cal
	self.latestPedometerInfo = [[PLTPedometerInfo alloc] initWithRequestType:pedometerInfo.requestType timestamp:pedometerInfo.timestamp steps:pedometerInfo.steps - self.pedometerOffset];
	
	// only notify for free fall once at high, and once at low.
	// *** NOTE: for first API version we notify low immediately after high! (since time in ff==yes is arbitrary) ***
	BOOL notifyFreeFallChanged = NO;
	self.latestFreeFallInfo = freeFallInfo;
	if (freeFallInfo.isInFreeFall) {
		if (!self.didGetFreeFallUp) {
			notifyFreeFallChanged = YES;
			self.didGetFreeFallUp = YES;
			self.didGetFreeFallDown = NO;
		}
		else {
			self.latestFreeFallInfo = [[PLTFreeFallInfo alloc] initWithRequestType:freeFallInfo.requestType timestamp:freeFallInfo.timestamp freeFall:NO];
			if (!self.didGetFreeFallDown) {
				notifyFreeFallChanged = YES;
				self.didGetFreeFallDown = YES;
			}
		}
	}
	else {
		self.didGetFreeFallUp = NO;
		self.didGetFreeFallDown = NO;
	}
	
	self.latestMagnetometerCalibrationInfo = magnetometerCalibrationInfo;
	self.latestGyroscopeCalibrationInfo = gyroscopeCalibrationInfo;
	
	// notify query observers
	
	for (NSDictionary *queryObserver in self.queryObservers) {
		id <PLTDeviceInfoObserver> observer = queryObserver[PLTQueryObserverKeyObserver];
		
		PLTInfo *newInfo = nil;
		PLTService service = [queryObserver[PLTQueryObserverKeyService] unsignedIntegerValue];
		switch (service) {
			case PLTServiceProximity:
				newInfo = self.latestProximityInfo;
				break;
			case PLTServiceWearingState:
				newInfo = self.latestWearingStateInfo;
				break;
			case PLTServiceOrientationTracking:
				newInfo = self.latestOrientationTrackingInfo;
				break;
			case PLTServicePedometer:
				newInfo = self.latestPedometerInfo;
				break;
			case PLTServiceFreeFall:
				newInfo = self.latestFreeFallInfo;
				break;
			case PLTServiceTaps:
				newInfo = self.latestTapsInfo;
				break;
			case PLTServiceMagnetometerCalStatus:
				newInfo = self.latestMagnetometerCalibrationInfo;
				break;
			case PLTServiceGyroscopeCalibrationStatus:
				newInfo = self.latestGyroscopeCalibrationInfo;
				break;
		}
		
		newInfo.requestType = PLTInfoRequestTypeQuery;
		
		if (newInfo) {
			[observer PLTDevice:self didUpdateInfo:newInfo];
		}
	}
	
	self.queryObservers = nil;
	
	// notify on change subscribers
	
	NSDate *date = [NSDate date];
	
	for (NSValue *v in self.subscribers) {
		NSMutableArray *subscriber = self.subscribers[v];
		
		for (NSMutableDictionary *subscription in subscriber) {
			if ([subscription[PLTSubscriptionKeyMode] isEqualToNumber:@(PLTSubscriptionModeOnChange)]) {
				
				PLTInfo *newInfo = nil;
				PLTService service = [subscription[PLTSubscriptionKeyService] unsignedIntegerValue];
				switch (service) {
					case PLTServiceProximity:
						newInfo = self.latestProximityInfo;
						break;
					case PLTServiceWearingState:
						newInfo = self.latestWearingStateInfo;
						break;
					case PLTServiceOrientationTracking:
						newInfo = self.latestOrientationTrackingInfo;
						break;
					case PLTServicePedometer:
						newInfo = self.latestPedometerInfo;
						break;
					case PLTServiceFreeFall:
						if (!notifyFreeFallChanged) continue;
						newInfo = self.latestFreeFallInfo;
						break;
					case PLTServiceTaps:
						if (!notifyTapsChanged) continue;
						newInfo = self.latestTapsInfo;
						break;
					case PLTServiceMagnetometerCalStatus:
						newInfo = self.latestMagnetometerCalibrationInfo;
						break;
					case PLTServiceGyroscopeCalibrationStatus:
						newInfo = self.latestGyroscopeCalibrationInfo;
						break;
				}
				
				if (newInfo) {
					PLTInfo *lastInfo = subscription[PLTSubscriptionKeyLastUpdateInfo];
					if (!lastInfo || ![newInfo isEqual:lastInfo] || notifyTapsChanged) { // ugh
						
						NSDate *lastUpdate = subscription[PLTSubscriptionKeyLastUpdateDate];
						NSTimeInterval updatePeriod = [subscription[PLTSubscriptionKeyPeriod] doubleValue];
						if (!lastUpdate || ([date timeIntervalSinceDate:lastUpdate] >= ((float)updatePeriod/1000.0))) {
							subscription[PLTSubscriptionKeyLastUpdateDate] = date;
							subscription[PLTSubscriptionKeyLastUpdateInfo] = newInfo;
							
							id<PLTDeviceInfoObserver> s = [v pointerValue];
							[s PLTDevice:self didUpdateInfo:newInfo];
						}
					}
				}
			}
		}
	}
}

- (void)checkTicker
{
	// check if there are any subscribers with mode == periodic, if so make sure the ticker is running. if not, kill the ticker.
	
	if (![self.subscribers count]) {
		//NSLog(@"No periodic subscribers. Killing ticker.");
		[self.ticker invalidate];
		self.ticker = nil;
	}
	
	BOOL foundSubscription = NO;
	for (NSValue *v in self.subscribers) {
		NSMutableArray *subscriber = self.subscribers[v];
		
		for (NSDictionary *subscription in subscriber) {
			if ([subscription[PLTSubscriptionKeyMode] isEqualToNumber:@(PLTSubscriptionModePeriodic)]) {
				foundSubscription = YES;
				break;
			}
		}
		if (foundSubscription) {
			break;
		}
	}
	
	if (foundSubscription) {
		//NSLog(@"Found a periodic subscription. Checking/starting ticker.");
		if (![self.ticker isValid]) {
			self.ticker = [NSTimer scheduledTimerWithTimeInterval:(1.0/TICKER_RATE) target:self selector:@selector(ticker:) userInfo:nil repeats:YES];
		}
	}
	else {
		//NSLog(@"No periodic subscriptions found. Killing ticker.");
		[self.ticker invalidate];
		self.ticker = nil;
	}
}

- (void)ticker:(NSTimer *)aTimer
{
	// see if any subscribers need an update
	
	NSDate *date = [NSDate date];
	
	for (NSValue *v in self.subscribers) {
		NSMutableArray *subscriber = self.subscribers[v];
		
		for (NSMutableDictionary *subscription in subscriber) {
			if ([subscription[PLTSubscriptionKeyMode] isEqualToNumber:@(PLTSubscriptionModePeriodic)]) {
				NSDate *lastUpdate = subscription[PLTSubscriptionKeyLastUpdateDate];
				NSTimeInterval updatePeriod = [subscription[PLTSubscriptionKeyPeriod] doubleValue];
				if (!lastUpdate || ([date timeIntervalSinceDate:lastUpdate] >= ((float)updatePeriod/1000.0))) {
					subscription[PLTSubscriptionKeyLastUpdateDate] = date;
					PLTInfo *info = nil;
					PLTService service = [subscription[PLTSubscriptionKeyService] unsignedIntegerValue];
					switch (service) {
						case PLTServiceProximity:
							info = self.latestProximityInfo;
							break;
						case PLTServiceWearingState:
							info = self.latestWearingStateInfo;
							break;
						case PLTServiceOrientationTracking:
							info = self.latestOrientationTrackingInfo;
							break;
						case PLTServicePedometer:
							info = self.latestPedometerInfo;
							break;
						case PLTServiceFreeFall:
							info = self.latestFreeFallInfo;
							break;
						case PLTServiceTaps:
							info = self.latestTapsInfo;
							break;
						case PLTServiceMagnetometerCalStatus:
							info = self.latestMagnetometerCalibrationInfo;
							break;
						case PLTServiceGyroscopeCalibrationStatus:
							info = self.latestGyroscopeCalibrationInfo;
							break;
					}
					
					if (info) {
						id<PLTDeviceInfoObserver> s = [v pointerValue];
						[s PLTDevice:self didUpdateInfo:info];
					}
				}
			}
		}
	}
}

- (BOOL)versionsCompatible
{
	return (self.fwMajorVersion==2 && self.fwMinorVersion==8);
	//return YES;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	switch (streamEvent) {
        case NSStreamEventErrorOccurred: {
            NSError *error = [theStream streamError];
            NSString *errorMessage = [NSString stringWithFormat:@"%@ (code %d)", [error localizedDescription], [error code]];
            NSLog(@"StreamEventError %@", errorMessage);
            break; }
            
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            break;
            
        case NSStreamEventHasBytesAvailable: {
            uint8_t buf[1024];
			const int pLen = 22;
            unsigned int len = pLen;
            len = [[self.session inputStream] read:buf maxLength:1];
            if (len == 0) return;
            
            while (buf[0] != 0x24) {
                len = [[self.session inputStream] read:buf maxLength:1];
                if (len==0) return;
            }
			
            len = [[self.session inputStream] read:(buf+1) maxLength:1023];
            
            if (len < 22) {
                NSLog(@"*** Message too small! Discarding. ***");
                return;
            }
			
			NSData *packetData = [NSData dataWithBytes:buf length:pLen]; // notice trim to pLen
			[self didGetNewPacket:packetData];
            break; }
			
		case NSStreamEventOpenCompleted:
		case NSStreamEventHasSpaceAvailable:
			break;
    }
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[PLTDevice class]]) {
		EAAccessory *compareAccessory = ((PLTDevice *)object).accessory;
		return (self.accessory.connectionID == compareAccessory.connectionID);
	}
	return NO;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTDevice: %p> {\n\tisConnectionOpen: %@\n\tname: %@\n\tmodel: %@\n\tserialNumber: %@\n\tfwMajorVersion: %u\n\tfwMinorVersion: %u\n}",
			self, (self.isConnectionOpen ? @"YES" : @"NO"), self.name, self.model, self.serialNumber, self.fwMajorVersion, self.fwMinorVersion];
}

@end
