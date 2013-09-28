//
//  PLTHeadsetManager.m
//
//  Created by Davis, Morgan on 3/27/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//  

#import "PLTHeadsetManager.h"
#import "MainWindowController.h"


//#define HS_STATS

#define PACKET_RATE_UPDATE_RATE		5.0 // Hz
#define DON_CALIBRATE_DELAY			2 // seconds


NSString *const PLTHeadsetDidConnectNotification =							@"PLTHeadsetDidConnectNotification";
NSString *const PLTHeadsetDidDisconnectNotification =						@"PLTHeadsetDidDisconnectNotification";
NSString *const PLTHeadsetInfoDidUpdateNotification =						@"PLTHeadsetInfoDidUpdateNotification";
NSString *const PLTHeadsetHeadTrackingCalibrationDidUpdateNotification =	@"PLTHeadsetHeadTrackingCalibrationDidUpdateNotification";


NSString *const PLTHeadsetInfoKeyPacketData =								@"pData";          // NSData containing raw 23-byte packet (not calibrated)
NSString *const PLTHeadsetInfoKeyCalibratedPacketData =						@"calPData";       // NSData containing raw 23-byte packet (calibrated)
NSString *const PLTHeadsetInfoKeyQuaternionData =							@"qData";          // NSData containing Vec4 (calibrated)
NSString *const PLTHeadsetInfoKeyRotationVectorData =						@"rotVecData";	   // NSData containing Vec3 (calibrated)
NSString *const PLTHeadsetInfoKeyTemperature =								@"temp";           // NSNumber containing degrees Celcius
NSString *const PLTHeadsetInfoKeyFreeFall =									@"freeFall";       // NSNumber containing boolean
NSString *const PLTHeadsetInfoKeyPedometerCount =							@"pedCount";       // NSNumber
NSString *const PLTHeadsetInfoKeyTapCount =									@"tapCount";       // NSNumber
NSString *const PLTHeadsetInfoKeyTapDirection =								@"tapDir";         // NSNumber containing PLTTapDirection
NSString *const PLTHeadsetInfoKeyMagnetometerCalibrationStatus =			@"magCal";         // NSNumber containing PLTMagnetometerCalibrationStatus
NSString *const PLTHeadsetInfoKeyGyroscopeCalibrationStatus =				@"gyroCal";        // NSNumber containing PLTGyroscopeCalibrationStatus
NSString *const PLTHeadsetInfoKeyMajorVersion =								@"majVers";        // NSNumber
NSString *const PLTHeadsetInfoKeyMinorVersion =								@"minVers";        // NSNumber
NSString *const PLTHeadsetInfoKeyIsDonned =									@"isDonned";	   // NSNumber

NSString *const PLTHeadsetHeadTrackingKeyCalibrationPacket =				@"PLTHeadsetHeadTrackingKeyCalibrationPacket"; // NSData containing Vec4


double *MultipliedQuaternions(double *p, double *q)
{
    // quaternion multiplication
    double *newquat = malloc(sizeof(double)*4);
    memset(newquat, 0, sizeof(double)*4);
    
    double quatmat[4][4] =
    {   { p[0], -p[1], -p[2], -p[3] },
        { p[1], p[0], -p[3], p[2] },
        { p[2], p[3], p[0], -p[1] },
        { p[3], -p[2], p[1], p[0] },
    };
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            newquat[i] += quatmat[i][j] * q[j];
        }
    }
    
    return newquat;
}

double *InverseQuaternion(double *quat)
{
    double *newquat = malloc(sizeof(double)*4);
    
    newquat[0] = quat[0];
    newquat[1] = -quat[1];
    newquat[2] = -quat[2];
    newquat[3] = -quat[3];
    
    return newquat;
}

Vec3 RotationVectorFromQuaternion(Vec4 quaternion)
{
	// heading
    float psi = 180.0 / 3.14159 * atan2((quaternion.y*quaternion.x + quaternion.w*quaternion.z), (quaternion.w*quaternion.w + quaternion.x*quaternion.x - 0.5));
    // pitch
    float theta = -180.0 / 3.14159 * atan2((quaternion.y*quaternion.z + quaternion.w*quaternion.x), (quaternion.w*quaternion.w + quaternion.z*quaternion.z - 0.5));
	// roll
	float phi = 180.0 / 3.14159 * asin(-2.0*quaternion.x*quaternion.z + 2.0*quaternion.w*quaternion.y);
    
	return (Vec3){ psi, theta, phi };
}


@interface PLTHeadsetManager () {
	double  *lastQuat;
    double  *calQuat;
}

- (void)log:(NSString *)text, ...;
- (BOOL)getQuaternionData:(NSData **)quaternionData rotationVectorData:(NSData **)rotationVectorData temperature:(NSNumber **)temperature
				 freeFall:(NSNumber **)freeFall pedometerCount:(NSNumber **)pedometerCount tapCount:(NSNumber **)tapCount tapDirection:(NSNumber **)tapDirection
magnetometerCalibrationStatus:(NSNumber **)magnetometerCalibrationStatus gyroscopeCalibrationStatus:(NSNumber **)gyroscopeCalibrationStatus
			 majorVersion:(NSNumber **)majorVersion minorVersion:(NSNumber **)minorVersion isDonned:(NSNumber **)donned calibratedPacketData:(NSData **)calibratedPacketData
		   fromPacketData:(NSData *)packetData;
- (void)log:(NSString *)format args:(NSString *)args, ...;
- (void)applicationDidBecomeActive:(NSNotification *)note;

- (void)startPacketRateTimer;
- (void)stopPacketRateTimer;
- (void)packetRateTimer:(NSTimer *)theTimer;

- (NSData *)packetDataWithCalibration:(double *)cal packet:(NSData *)inPacket; // TEMPORARY

@property(nonatomic,assign) BOOL            histeresisExcited;
@property(nonatomic,assign) long long       oldtime;
@property(nonatomic,retain) NSDictionary    *_latestInfo;
@property(nonatomic,strong) NSTimer			*packetRateTimer;
@property(nonatomic,assign) NSInteger		packetRateCounter;
@property(nonatomic,strong) NSDate			*packetRateCounterDate;
@property(nonatomic,strong) NSData			*lastPacketData;

@end


@implementation PLTHeadsetManager

@dynamic latestInfo;

- (NSDictionary *)latestInfo
{
    return self._latestInfo;
}

#pragma mark - Public

+ (PLTHeadsetManager *)sharedManager
{
    static PLTHeadsetManager *manager = nil;
    if (!manager) {
        manager = [[PLTHeadsetManager alloc] init];
    }
    return manager;
}

- (NSDictionary *)infoFromPacketData:(NSData *)packetData
{
	NSData *quaternionData = nil;
	NSData *rotationVectorData = nil;
	NSNumber *temperature = nil;
	NSNumber *freeFall = nil;
	NSNumber *pedometerCount = nil;
	NSNumber *tapCount = nil;
	NSNumber *tapDirection = nil;
	NSNumber *magnetometerCalibrationStatus = nil;
	NSNumber *gyroscopeCalibrationStatus = nil;
	NSNumber *majorVersion = nil;
	NSNumber *minorVersion = nil;
	NSData *calibratedPacketData = nil;
	NSNumber *isDonned = nil;
	
	if ([self getQuaternionData:&quaternionData rotationVectorData:&rotationVectorData temperature:&temperature freeFall:&freeFall pedometerCount:&pedometerCount
					   tapCount:&tapCount tapDirection:&tapDirection magnetometerCalibrationStatus:&magnetometerCalibrationStatus gyroscopeCalibrationStatus:&gyroscopeCalibrationStatus
				   majorVersion:&majorVersion minorVersion:&minorVersion isDonned:&isDonned calibratedPacketData:&calibratedPacketData fromPacketData:packetData] ) {
		
		if ((self.headTrackingCalibrationTriggers & PLTHeadTrackingCalibrationTriggerDon) && [isDonned boolValue] && ![self.latestInfo[PLTHeadsetInfoKeyIsDonned] boolValue]) {
			// Don event is a calibration trigger. Do calibration.
			[self performSelector:@selector(updateCalibration) withObject:nil afterDelay:DON_CALIBRATE_DELAY];
		}
		
		NSData *calPacketData = packetData;
		calPacketData = calibratedPacketData;
		
//		if (calQuat[0] && calQuat[1] && calQuat[2] && calQuat[3] && HEADSET_CONNECTED) {
//			DLog(@"cal");
//			
//			//Vec4 quaternion = { -nCalQuat[1], nCalQuat[2], -nCalQuat[3], nCalQuat[0] };
//			Vec4 quatVec;
//			[quaternionData getBytes:&quatVec length:[quaternionData length]];
//			double quat[4];
//			quat[0] = quatVec.w;
//			quat[1] = -quatVec.x;
//			quat[2] = quatVec.y;
//			quat[3] = -quatVec.z;
//			
//			// correct for calibration
//			double *invCalQuat = InverseQuaternion(calQuat);
//			double *nCalQuat = MultipliedQuaternions(invCalQuat, quat);
//			
//			calPacketData = [self packetDataWithCalibration:nCalQuat packet:packetData];
//		}
		
		NSDictionary *newInfo = @{PLTHeadsetInfoKeyPacketData : packetData,
							PLTHeadsetInfoKeyCalibratedPacketData : calPacketData,
							PLTHeadsetInfoKeyQuaternionData : quaternionData,
							PLTHeadsetInfoKeyRotationVectorData : rotationVectorData,
							PLTHeadsetInfoKeyTemperature : temperature,
							PLTHeadsetInfoKeyFreeFall : freeFall,
							PLTHeadsetInfoKeyPedometerCount : pedometerCount,
							PLTHeadsetInfoKeyTapCount : tapCount,
							PLTHeadsetInfoKeyTapDirection : tapDirection,
							PLTHeadsetInfoKeyMagnetometerCalibrationStatus : magnetometerCalibrationStatus,
							PLTHeadsetInfoKeyGyroscopeCalibrationStatus : gyroscopeCalibrationStatus,
							PLTHeadsetInfoKeyMajorVersion : majorVersion,
							PLTHeadsetInfoKeyMinorVersion : minorVersion,
							PLTHeadsetInfoKeyIsDonned : isDonned };
		return newInfo;
	}
	return nil;
}

#pragma mark - Private

- (void)log:(NSString *)text, ...
{
	va_list list;
	va_start(list, text);
    NSString *message = [[NSString alloc] initWithFormat:text arguments:list];
	va_end(list);
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTHTCamNotificationLogMessage object:nil userInfo:@{PLTHTCamNotificationKeyLogMessage: message}];
}

- (BOOL)getQuaternionData:(NSData **)quaternionData rotationVectorData:(NSData **)rotationVectorData temperature:(NSNumber **)temperature
				 freeFall:(NSNumber **)freeFall pedometerCount:(NSNumber **)pedometerCount tapCount:(NSNumber **)tapCount tapDirection:(NSNumber **)tapDirection
magnetometerCalibrationStatus:(NSNumber **)magnetometerCalibrationStatus gyroscopeCalibrationStatus:(NSNumber **)gyroscopeCalibrationStatus
			 majorVersion:(NSNumber **)majorVersion minorVersion:(NSNumber **)minorVersion isDonned:(NSNumber **)isDonned calibratedPacketData:(NSData **)calibratedPacketData
		   fromPacketData:(NSData *)packetData
{
    NSUInteger len = [packetData length];
    uint8_t *buf = malloc(len);
    [packetData getBytes:buf length:len];
    
    if (!(buf[0] == 0x24) && !(buf[21] == 0xd) && !(buf[22] == 0xa)) {
        DLog(@"*** Badly formed or misaligned packet. Discarding. ***");
        return NO;
    }
    
//	NSMutableString *hexStr = [NSMutableString stringWithCapacity:len*2];
//	for (int i = 0; i < len; i++) [hexStr appendFormat:@"%02x", buf[i]];
//	DLog(@"Raw packet:\t\t\t%@",hexStr);
    
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
    
    // new for extra info DA IDES OF MARCH
    *temperature = @(buf[2]);
    *freeFall = @(buf[6]);
    temp = (((uint16_t)buf[9]) << 8) + ((uint16_t)buf[10]);
    *pedometerCount = @((uint16_t)temp);
    *tapDirection = @(buf[13]);
    *tapCount = @(buf[14]);
    *magnetometerCalibrationStatus = @(buf[17]);
    *gyroscopeCalibrationStatus = @(buf[18]);
    *majorVersion = @(buf[19]);
    *minorVersion = @(buf[20]);
	*isDonned = @(buf[5]);
    
    // process for use
    for (int i = 0; i < 4; i++) {
        if (quatn[i] > 32767) {
            quatn[i] -= 65536;
        }
        quat[i] = ((double)quatn[i]) / 16384.0f;// 32768.0f
	}
	
	// save for calibration (if the user shakes the devise)
	memcpy(lastQuat, quat, sizeof(double)*4);
    
    for (int i=0; i<3; i++) {
        if (quat[i] > 1.0001f) {
            DLog(@"Bad quaternion! %f, %f, %f, %f",quat[0],quat[1],quat[2],quat[3]);
            *quaternionData = nil;
            *rotationVectorData = nil;
			return NO;
        }
    }
    
	double *nCalQuat = quat;
	if (HEADSET_CONNECTED) {
		// correct for calibration
		double *invCalQuat = InverseQuaternion(calQuat);
		nCalQuat = MultipliedQuaternions(invCalQuat, quat);
	}
	
	*calibratedPacketData = [self packetDataWithCalibration:nCalQuat packet:packetData];
    
    for (int i=0; i<3; i++) {
        if (nCalQuat[i] > 1.0001f) {
            DLog(@"Bad quatquaternion after cal! %f, %f, %f, %f",nCalQuat[0],nCalQuat[1],nCalQuat[2],nCalQuat[3]);
            *quaternionData = nil;
            *rotationVectorData = nil;
			return NO;
        }
    }
    
    printf(".");
    
    Vec4 quaternion = { -nCalQuat[1], nCalQuat[2], -nCalQuat[3], nCalQuat[0] };
    Vec3 rotationVector = RotationVectorFromQuaternion(quaternion);
    
    *quaternionData = [NSData dataWithBytes:&quaternion length:sizeof(Vec4)];
    *rotationVectorData = [NSData dataWithBytes:&rotationVector length:sizeof(Vec3)];
    
    return YES;
}

- (void)startPacketRateTimer
{
	if (![self.packetRateTimer isValid]) {
		self.packetRateCounter = 0;
		self.packetRateCounterDate = [NSDate date];
		self.packetRateTimer = [NSTimer scheduledTimerWithTimeInterval:PACKET_RATE_UPDATE_RATE
																target:self selector:@selector(packetRateTimer:)
															  userInfo:nil repeats:YES];
	}
}

- (void)stopPacketRateTimer
{
	if ([self.packetRateTimer isValid]) {
		[self.packetRateTimer invalidate];
		self.packetRateTimer = nil;
	}
}

- (void)packetRateTimer:(NSTimer *)theTimer
{
	float avg = ((float)self.packetRateCounter) / [[NSDate date] timeIntervalSinceDate:self.packetRateCounterDate];
	DLog(@"Headset packet receive rate: %.1f messages/sec",avg);
	
	self.packetRateCounter = 0;
	self.packetRateCounterDate = [NSDate date];
}

- (NSData *)packetDataWithCalibration:(double *)cal packet:(NSData *)inPacket // TEMPORARY
{
	// this is pretty inconvenient... get a packet over MFi wire, decode it, apply cal,
	// then RE-PACK it to look like an MFi packet (with header and all).
	
	uint8_t *buf = malloc([inPacket length]);
	[inPacket getBytes:buf length:[inPacket length]];
	uint16_t quaternion[8];
	memset(&quaternion, 0, 8);
	
	quaternion[0] = (uint16_t)lround(cal[0] * 16384.0f);
	quaternion[1] = (uint16_t)lround(cal[1] * 16384.0f);
	quaternion[2] = (uint16_t)lround(cal[2] * 16384.0f);
	quaternion[3] = (uint16_t)lround(cal[3] * 16384.0f);
	
	buf[2+1] = quaternion[0] >> 8;
	quaternion[0] = (quaternion[0] << 8) >> 8;
	buf[3+1] = (uint8_t)quaternion[0];
	
	buf[6+1] = quaternion[1] >> 8;
	quaternion[1] = (quaternion[1] << 8) >> 8;
	buf[7+1] = (uint8_t)quaternion[1];
	
	buf[10+1] = quaternion[2] >> 8;
	quaternion[2] = (quaternion[2] << 8) >> 8;
	buf[11+1] = (uint8_t)quaternion[2];
	
	buf[14+1] = quaternion[3] >> 8;
	quaternion[3] = (quaternion[3] << 8) >> 8;
	buf[15+1] = (uint8_t)quaternion[3];
	
	NSData *packetData = [NSData dataWithBytes:buf length:[inPacket length]];
	
	//	NSMutableString *hexStr = [NSMutableString stringWithCapacity:[inPacket length]*2];
	//	for (int i = 0; i < [inPacket length]; i++) [hexStr appendFormat:@"%02x", buf[i]];
	//	DLog(@"Calibrated packet:\t%@",hexStr);
	
	return packetData;
}

#pragma mark - NSObject

- (id)init
{
    if (self = [super init]) {
		// set starting calibration quat to 1,0,0,0 and allocate space for lastQuat
        calQuat = malloc(sizeof(double)*4);
        memset(calQuat, 0, sizeof(double)*4);
        calQuat[0] = 1;
        lastQuat = malloc(sizeof(double)*4);
        memset(lastQuat, 0, sizeof(double)*4);
    }
    return self;
}

@end
