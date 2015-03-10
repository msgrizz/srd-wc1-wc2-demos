//
//  ViewController.m
//  WC2RawSubscribe
//
//  Created by Morgan Davis on 12/13/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "ViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import "PLTDevice_Internal.h"
#import "BRDevice.h"
#import "BREvent.h"
#import "BRDevice_Private.h"
#import "BRRemoteDevice.h"
#import "BRSubscribeToServicesCommand.h"
#import "BRSubscribedServiceDataEvent.h"
#import "BRDeviceUtilities.h"
#import "BRQueryServicesDataSettingRequest.h"
#import "BRQueryServicesDataSettingResult.h"
#import "BRConfigureSignalStrengthEventsCommand.h"


typedef struct {
	float x;
	float y;
	float z;
} PLTVec3;

PLTVec3 PLTVec3FromDeckardBlob(NSData *blob)
{
	struct Q16 {
		int16_t m;
		uint16_t n;
	};
	struct RawVec3 {
		struct Q16 x;
		struct Q16 y;
		struct Q16 z;
	};
	float d = exp2f(16);
	struct RawVec3 rv3;
	
	[blob getBytes:&rv3 length:sizeof(rv3)];
	
	rv3.x.m = ntohs(rv3.x.m);
	rv3.x.n = ntohs(rv3.x.n);
	rv3.y.m = ntohs(rv3.y.m);
	rv3.y.n = ntohs(rv3.y.n);
	rv3.z.m = ntohs(rv3.z.m);
	rv3.z.n = ntohs(rv3.z.n);
	
	return (PLTVec3) {
		(float)rv3.x.m + ((float)rv3.x.n)/d,
		(float)rv3.y.m + ((float)rv3.y.n)/d,
		(float)rv3.z.m + ((float)rv3.z.n)/d };
}

double BRR2D(double d)
{
	return d * (180.0/M_PI);
}

PLTEulerAngles BREulerAnglesFromQuaternion(PLTQuaternion q)
{
	double q0 = q.w;
	double q1 = q.x;
	double q2 = q.y;
	double q3 = q.z;
	
	double m22 = 2*pow(q0,2) + 2*pow(q2,2) - 1;
	double m21 = 2*q1*q2 - 2*q0*q3;
	double m13 = 2*q1*q3 - 2*q0*q2;
	double m23 = 2*q2*q3 + 2*q0*q1;
	double m33 = 2*pow(q0,2) + 2*pow(q3,2) - 1;
	
	double psi = -BRR2D(atan2(m21,m22));
	double theta = BRR2D(asin(m23));
	double phi = -BRR2D(atan2(m13, m33));
	
	return (PLTEulerAngles){ psi, theta, phi };
}


@interface ViewController () <BRDeviceDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic,retain) BRDevice				*device;
@property(nonatomic,retain) BRRemoteDevice			*sensorsDevice;
@property(nonatomic,retain) IBOutlet UILabel		*connectedLabel;
@property(nonatomic,retain) IBOutlet UIButton		*connectButton;
@property(nonatomic,retain) IBOutlet UITextView		*textView;
@property(nonatomic,retain) IBOutlet UILabel		*orientationLabel;
@property(nonatomic,retain) IBOutlet UILabel		*headingLabel;
@property(nonatomic,retain) IBOutlet UILabel		*accelXLabel;
@property(nonatomic,retain) IBOutlet UILabel		*accelYLabel;
@property(nonatomic,retain) IBOutlet UILabel		*accelZLabel;
@property(nonatomic,retain) IBOutlet UILabel		*magCalStatusLabel;
@property(nonatomic,retain) IBOutlet UILabel		*magXLabel;
@property(nonatomic,retain) IBOutlet UILabel		*magYLabel;
@property(nonatomic,retain) IBOutlet UILabel		*magZLabel;
@property(nonatomic,retain) IBOutlet UILabel		*gyroCalStatusLabel;
@property(nonatomic,retain) IBOutlet UILabel		*angVXLabel;
@property(nonatomic,retain) IBOutlet UILabel		*angVYLabel;
@property(nonatomic,retain) IBOutlet UILabel		*angVZLabel;


@property(nonatomic,retain) NSArray						*services;
@property(nonatomic,retain) IBOutlet UIPickerView		*servicePicker;
@property(nonatomic,retain) IBOutlet UISegmentedControl	*modeSegmentedControl;
@property(nonatomic,retain) IBOutlet UISegmentedControl	*periodSegmentedControl;


- (PLTQuaternion)quaternionFromServiceData:(NSData *)serviceData;
- (void)checkUI;
- (void)scrollLog;
- (void)queryCal;
- (void)subscribeCal;
- (BOOL)calibrationFromServiceData:(NSData *)serviceData;
- (IBAction)connectButton:(id)sender;
- (IBAction)allSubButton:(id)sender;
- (IBAction)allUnsubButton:(id)sender;
- (IBAction)orientationSubButton:(id)sender;
- (IBAction)orientationUnsubButton:(id)sender;
- (IBAction)headingSubButton:(id)sender;
- (IBAction)headingUnsubButton:(id)sender;
- (IBAction)magSubButton:(id)sender;
- (IBAction)magUnsubButton:(id)sender;
- (IBAction)accelSubButton:(id)sender;
- (IBAction)accelUnsubButton:(id)sender;
- (IBAction)gyroSubButton:(id)sender;
- (IBAction)gyroUnsubButton:(id)sender;

- (IBAction)disconnectButton:(id)sender;
- (IBAction)sendSubscriptionButton:(id)sender;
- (IBAction)queryButton:(id)sender;
- (NSInteger)serviceIDFromPicker;

@end


@implementation ViewController

#pragma mark - Private

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
	
	PLTQuaternion q = (PLTQuaternion){fw, fx, fy, fz};
	if (q.w>1.0001f || q.x>1.0001f || q.y>1.0001f || q.z>1.0001f) {
		NSLog(@"Bad quaternion! { %f, %f, %f, %f }", q.w, q.x, q.y, q.z);
	}
	else {
		return q;
	}
	
	return (PLTQuaternion){1, 0, 0, 0};
}

- (void)checkUI
{
	if (self.sensorsDevice.isConnected) {
		self.connectedLabel.text = @"Connected";
		self.connectButton.titleLabel.text = @"Disconnect";
	}
	else {
		self.connectedLabel.text = @"Disonnected";
		self.connectButton.titleLabel.text = @"Connect";
	}
}

- (void)scrollLog
{
	if ([self.textView.text length] >= 10000) {
		self.textView.text = [self.textView.text substringFromIndex:1000];
	}
	
	[self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
}

- (void)queryCal
{
//	BRQueryServicesDataSettingRequest *req = [BRQueryServicesDataSettingRequest requestWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus
//																					  characteristic:0];
//	[self.sensorsDevice sendMessage:req];
//	BRQueryServicesDataSettingRequest *req2 = [BRQueryServicesDataSettingRequest requestWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagnetometerCalibrationStatus
//																					   characteristic:0];
//	[self.sensorsDevice sendMessage:req2];
}

- (void)subscribeCal
{
//	BRSubscribeToServicesCommand *cmd = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus
//																			characteristic:0
//																					  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
//																					period:0];
//	[self.sensorsDevice sendMessage:cmd];
//	BRSubscribeToServicesCommand *cmd2 = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagnetometerCalibrationStatus
//																			 characteristic:0
//																					   mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
//																					 period:0];
//	[self.sensorsDevice sendMessage:cmd2];
}

- (BOOL)calibrationFromServiceData:(NSData *)serviceData
{
	uint8_t cal;
	[serviceData getBytes:&cal length:sizeof(uint8_t)];
	return (cal == 3);
}

- (IBAction)connectButton:(id)sender
{
	self.magCalStatusLabel.text = @"-";
	self.gyroCalStatusLabel.text = @"-";
	if (!self.device.isConnected) {
		NSArray *devices = [PLTDevice availableDevices];
		if ([devices count]) {
			EAAccessory *accessory = ((PLTDevice *)devices[0]).accessory;
			BRDevice *device = [BRDevice deviceWithAccessory:accessory];
			self.device = device;
			self.device.delegate = self;
			[self.device openConnection];
		}
		else {
			NSLog(@"No devices.");
			self.connectedLabel.text = @"No IAP devices";
		}
	}
	else {
		[self.device closeConnection];
	}
}

- (IBAction)allSubButton:(id)sender
{
	for (PLTService s=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Orientation;
		 s<=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus;
		 s++) {
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:s
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																							period:0];
		[self.sensorsDevice sendMessage:message];
	}
	
	for (PLTService s=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration;
		 s<=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField;
		 s++) {
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:s
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																							period:0];
		[self.sensorsDevice sendMessage:message];
	}
}

- (IBAction)allUnsubButton:(id)sender
{
	for (PLTService s=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Orientation;
		 s<=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus;
		 s++) {
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:s
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																							period:0];
		[self.sensorsDevice sendMessage:message];
	}
	
	for (PLTService s=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration;
		 s<=BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField;
		 s++) {
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:s
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																							period:0];
		[self.sensorsDevice sendMessage:message];
	}
}

- (IBAction)orientationSubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Orientation
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModePeriodic
																						period:50];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)orientationUnsubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Orientation
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)headingSubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Heading
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)headingUnsubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Heading
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)magSubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)magUnsubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)accelSubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)accelUnsubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)gyroSubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_AngularVelocity
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)gyroUnsubButton:(id)sender
{
	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_AngularVelocity
																				characteristic:0
																						  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																						period:0];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)disconnectButton:(id)sender
{
	if (self.device.isConnected) {
		[self.device closeConnection];
	}
}

- (IBAction)sendSubscriptionButton:(id)sender
{
	NSInteger serviceID = [self serviceIDFromPicker];
	uint16_t mode = [self.modeSegmentedControl selectedSegmentIndex];
	NSArray *periods = @[@0, @50, @100, @300];
	uint16_t period = [periods[[self.modeSegmentedControl selectedSegmentIndex]] integerValue];
	
	NSLog(@"sendSubscriptionButton serviceID: 0x%04X mode: %d period: %d", serviceID, mode, period);
	
	if (serviceID == -1) {
		for (NSArray *l in self.services) {
			BRConfigureSignalStrengthEventsCommand *command = [BRConfigureSignalStrengthEventsCommand commandWithConnectionId:0
																													   enable:YES
																													  dononly:NO
																														trend:NO
																											  reportRssiAudio:NO 
																										   reportNearFarAudio:NO
																										  reportNearFarToBase:NO 
																												  sensitivity:0
																												nearThreshold:71
																												   maxTimeout:UINT16_MAX];
			[self.sensorsDevice sendMessage:command];
			
			BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:[l[1] unsignedIntegerValue]
																						characteristic:0
																								  mode:mode
																								period:period];
			[self.sensorsDevice sendMessage:message];
		}
	}
	else {
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:serviceID
																					characteristic:0
																							  mode:mode
																							period:period];
		[self.sensorsDevice sendMessage:message];
	}
}

- (IBAction)queryButton:(id)sender
{
	NSInteger serviceID = [self serviceIDFromPicker];
	
	NSLog(@"queryButton serviceID: %04X", serviceID);
	
	if (serviceID == -1) {
		for (NSArray *l in self.services) {
			BRQueryServicesDataSettingRequest *message = [BRQueryServicesDataSettingRequest requestWithServiceID:[l[1] unsignedIntegerValue]
																								  characteristic:0];
			[self.sensorsDevice sendMessage:message];
		}
	}
	else {
		BRQueryServicesDataSettingRequest *message = [BRQueryServicesDataSettingRequest requestWithServiceID:serviceID
																							  characteristic:0];
		[self.sensorsDevice sendMessage:message];
	}
}

- (NSInteger)serviceIDFromPicker
{
	NSUInteger selected = [self.servicePicker selectedRowInComponent:0];
	return [self.services[selected][1] integerValue];
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidConnect: %@", device);
	
	if (device == self.sensorsDevice) {
		[self checkUI];
	}
	
	[self queryCal];
	[self subscribeCal];
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidDisconnect: %@", device);
	
	if (device == self.device) {
		self.device = nil;
		self.sensorsDevice = nil;
	}
	else if (device == self.sensorsDevice) {
		self.sensorsDevice = nil;
	}
	
	[self checkUI];
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
	NSLog(@"BRDevice: %@ didFailConnectWithError: %d", device, ioBTError);
	
	self.device = nil;
	self.sensorsDevice = nil;
//	if (device == self.device) {
//		self.device = nil;
//	}
//	else if (device == self.sensorsDevice) {
//		self.sensorsDevice = nil;
//	}
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
	NSLog(@"BRDevice: %@ didReceiveEvent: %@", device, event);
	
	if ([event isKindOfClass:[BRSubscribedServiceDataEvent class]]) {
		BRSubscribedServiceDataEvent *serviceDataEvent = (BRSubscribedServiceDataEvent *)event;
		uint16_t serviceID = serviceDataEvent.serviceID;
		NSData *serviceData = serviceDataEvent.serviceData;
		float d = exp2f(16);
		switch (serviceID) {
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Heading: {
				struct mn {
					uint16_t m;
					uint16_t n;
				};
				struct mn rh;
				[serviceData getBytes:&rh length:sizeof(rh)];
				rh.m = ntohs(rh.m);
				rh.n = ntohs(rh.n);
				float h = (float)rh.m + ((float)rh.n)/d;
				self.headingLabel.text = [NSString stringWithFormat:@"%03.1f deg", h];
				break; }
				
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration: {
				PLTVec3 v3 = PLTVec3FromDeckardBlob(serviceData);
				self.accelXLabel.text = [NSString stringWithFormat:@"%+02.4f g", v3.x];
				self.accelYLabel.text = [NSString stringWithFormat:@"%+02.4f g", v3.y];
				self.accelZLabel.text = [NSString stringWithFormat:@"%+02.4f g", v3.z];
				
//				PLTVec3 v3_2 = PLTVec3FromDeckardBlob2(serviceData);
//				NSLog(@"x_2: %+05.4f", v3_2.x);
//				NSLog(@"y_2: %+05.4f", v3_2.y);
//				NSLog(@"z_2: %+05.4f", v3_2.z);
				break; }
				
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField: {
				PLTVec3 v3 = PLTVec3FromDeckardBlob(serviceData);
				self.magXLabel.text = [NSString stringWithFormat:@"%+07.1f µT", v3.x];
				self.magYLabel.text = [NSString stringWithFormat:@"%+07.1f µT", v3.y];
				self.magZLabel.text = [NSString stringWithFormat:@"%+07.1f µT", v3.z];
				break; }
				
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_AngularVelocity: {
				PLTVec3 v3 = PLTVec3FromDeckardBlob(serviceData);
				self.angVXLabel.text = [NSString stringWithFormat:@"%+06.1f deg/sec", v3.x];
				self.angVYLabel.text = [NSString stringWithFormat:@"%+06.1f deg/sec", v3.y];
				self.angVZLabel.text = [NSString stringWithFormat:@"%+06.1f deg/sec", v3.z];
				break; }
				
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus: {
				BOOL cal = [self calibrationFromServiceData:serviceData];
				self.gyroCalStatusLabel.text = (cal ? @"calibrated" : @"not calibrated");
				
				if (cal) {
					BRSubscribeToServicesCommand *cmd = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus
																							characteristic:0
																									  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																									period:0];
					[self.sensorsDevice sendMessage:cmd];
				}
				break; }
				
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagnetometerCalibrationStatus: {
				BOOL cal = [self calibrationFromServiceData:serviceData];
				self.magCalStatusLabel.text = (cal ? @"calibrated" : @"not calibrated");
				break; }
				
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_Orientation: {
				PLTQuaternion quaternion = [self quaternionFromServiceData:serviceData];
				PLTEulerAngles eulerAngles = BREulerAnglesFromQuaternion(quaternion);	
				//NSLog(@"{ %.4f, %.4f, %.4f }", eulerAngles.x, eulerAngles.y, eulerAngles.z);
				self.orientationLabel.text = [NSString stringWithFormat:@"{ %.1f, %.1f, %.1f }", eulerAngles.x, eulerAngles.y, eulerAngles.z];
				break; }
		}
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResult:(BRSettingResult *)result
{
	NSLog(@"BRDevice: %@ didReceiveSettingResult: %@", device, result);
	
	if ([result isKindOfClass:[BRQueryServicesDataSettingResult class]]) {
		BRQueryServicesDataSettingResult *serviceDataResult = (BRQueryServicesDataSettingResult *)result;
		uint16_t serviceID = serviceDataResult.serviceID;
		NSData *serviceData = serviceDataResult.servicedata;
		switch (serviceID) {
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus: {
				BOOL cal = [self calibrationFromServiceData:serviceData];
				self.gyroCalStatusLabel.text = (cal ? @"calibrated" : @"not calibrated");
				
//				if (cal) {
//					BRSubscribeToServicesCommand *cmd = [BRSubscribeToServicesCommand commandWithServiceID:BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus
//																							characteristic:0
//																									  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
//																									period:0];
//					[self.sensorsDevice sendMessage:cmd];
//				}
				break; }
				
			case BRDefinedValue_SubscribeToServicesCommand_ServiceID_ServiceID_MagnetometerCalibrationStatus: {
				BOOL cal = [self calibrationFromServiceData:serviceData];
				self.magCalStatusLabel.text = (cal ? @"calibrated" : @"not calibrated");
				break; }
		}
	}
}

- (void)BRDevice:(BRDevice *)device didRaiseSettingException:(BRException *)exception
{
	NSLog(@"BRDevice: %@ didRaiseSettingException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didRaiseCommandException:(BRException *)exception
{
	NSLog(@"BRDevice: %@ didRaiseCommandException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice
{
	NSLog(@"BRDevice: %@ didFindRemoteDevice: %@", device, remoteDevice);
	
	if (remoteDevice.port == 0x5) {
		self.sensorsDevice = remoteDevice;
		self.sensorsDevice.delegate = self;
		[self.sensorsDevice openConnection];
	}
}

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
	//NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSString *hexString = BRDeviceHexStringFromData(data, 2);
	//NSLog(@"--> %@", hexString);
	//self.textView.text = [NSString stringWithFormat:@"--> %@", hexString];
	self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"--> %@\n",hexString]];
	//self.textView.selectedRange = NSMakeRange(self.textView.text.length - 1, 0);
	[self scrollLog];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	//NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSString *hexString = BRDeviceHexStringFromData(data, 2);
	//NSLog(@"<-- %@", hexString);
	//self.textView.text = [NSString stringWithFormat:@"<-- %@", hexString];
	self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"<-- %@\n",hexString]];
	//self.textView.selectedRange = NSMakeRange(self.textView.text.length - 1, 0);
	[self scrollLog];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return self.services[row][0];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.services count];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.textView.text = @"";
	
	self.services = @[
					  @[@"ALL", @(-1)],
					  @[@"Orientation, 0x0000", @(0x0000)],
					  @[@"Heading, 0x0001",  @(0x0001)],
					  @[@"Pedometer, 0x0002",  @(0x0002)],
					  @[@"FreeFal, 0x0003", @(0x0003)],
					  @[@"Taps, 0x0004", @(0x0004)],
					  @[@"MagCal, 0x0005", @(0x0005)],
					  @[@"GyroCal, 0x0006", @(0x0006)],
					  @[@"Acceleration, 0x0013", @(0x0013)],
					  @[@"AngularVelocity, 0x0014", @(0x0014)],
					  @[@"MagneticField, 0x0015", @(0x0015)]
					  ];
}

@end
