//
//  MainWindowController.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MainWindowController.h"

#import "BRDevice.h"
#import "BRRemoteDevice.h"
#import "NSData+HexStrings.h"
#import "BRMessage.h"
#import "BRSubscribeToServiceCommand.h"
#import "BRWearingStateSettingRequest.h"
#import "BRSignalStrengthSettingRequest.h"
#import "BRSubscribeToSignalStrengthCommand.h"
#import "BRServiceDataSettingRequest.h"
#import "BRDeviceInfoSettingRequest.h"
#import "BRWearingStateEvent.h"
#import "BROrientationTrackingEvent.h"
#import "BRSignalStrengthEvent.h"
#import "BRTapsEvent.h"
#import "BRFreeFallEvent.h"
#import "BRPedometerEvent.h"
#import "BRGyroscopeCalStatusEvent.h"
#import "BRWearingStateSettingResponse.h"
#import "BRSignalStrengthSettingResponse.h"
#import "BROrientationTrackingSettingResponse.h"
#import "BRTapsSettingResponse.h"
#import "BRFreeFallSettingResponse.h"
#import "BRPedometerSettingResponse.h"
#import "BRGyroscopeCalStatusSettingResponse.h"
#import "BRCalibratePedometerServiceCommand.h"
#import "BRServiceCalibrationSettingRequest.h"

#import "BRDeviceConnectedEvent.h"

#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
#import <IOBluetooth/IOBluetooth.h>

#import "BRRawMessage.h"


typedef struct {
	double x;
	double y;
	double z;
} BREulerAngles;

double BRR2D(double d)
{
	return d * (180.0/M_PI);
}

BREulerAngles BREulerAnglesFromQuaternion(BRQuaternion q)
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
	
    return (BREulerAngles){ psi, theta, phi };
}


@interface MainWindowController () <BRDeviceDelegate>

- (IBAction)openConnectionButton:(id)sender;
- (IBAction)closeConnectionButton:(id)sender;
- (IBAction)subscribeToServicesButton:(id)sender;
- (IBAction)unsubscribeFromServicesButton:(id)sender;
- (IBAction)queryDeviceInfoButton:(id)sender;
- (IBAction)queryWearingStateButton:(id)sender;
- (IBAction)querySignalStrengthButton:(id)sender;
- (IBAction)queryServicesButton:(id)sender;
- (IBAction)subscribeToSignalStrengthButton:(id)sender;
- (void)enableUI;
- (void)disableUI;

@property(nonatomic,retain) BRDevice *device;
@property(nonatomic,retain) BRRemoteDevice *sensorsDevice;

@property(nonatomic,assign) IBOutlet NSButton               *closeConnectionButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryWearingStateButton;
@property(nonatomic,assign) IBOutlet NSButton               *querySignalStrengthButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryDeviceInfoButton;
@property(nonatomic,assign) IBOutlet NSButton               *querySubscribeToServicesButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryUnsubscriberFromServicesButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryQueryServicesButton;
@property(nonatomic,assign) IBOutlet NSButton               *subscribeToSignalStrengthButton;
@property(nonatomic,assign) IBOutlet NSTextField            *connectedTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *wearingStateTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *signalStrengthTextField;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *headingIndicator;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *pitchIndicator;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *rollIndicator;
@property(nonatomic,assign) IBOutlet NSTextField            *freeFallTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *tapsTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *pedometerTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *gyroCalTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *dataTextField;

@end


@implementation MainWindowController

#pragma mark - Private

- (IBAction)openConnectionButton:(id)sender
{
	if (!self.device) {
		NSArray *devices = [PLTDevice availableDevices];
		if ([devices count]) {
			NSString *macString = ((PLTDevice *)devices[0]).address;
			self.device = [BRDevice deviceWithAddress:macString]; 
			self.device.delegate = self;
			[self.device openConnection];
		}
	}
}

- (IBAction)closeConnectionButton:(id)sender
{
    [self.device closeConnection];
}

- (IBAction)queryWearingStateButton:(id)sender
{
    BRWearingStateSettingRequest *request = (BRWearingStateSettingRequest *)[BRWearingStateSettingRequest request];
    [self.device sendMessage:request];
}

- (IBAction)subscribeToSignalStrengthButton:(id)sender
{
    BRSubscribeToSignalStrengthCommand *command = [BRSubscribeToSignalStrengthCommand commandWithSubscription:YES connectionID:0];
    [self.device sendMessage:command];
}

- (IBAction)querySignalStrengthButton:(id)sender
{
    BRSignalStrengthSettingRequest *request = (BRSignalStrengthSettingRequest *)[BRSignalStrengthSettingRequest request];
    [self.device sendMessage:request];
}

- (IBAction)queryDeviceInfoButton:(id)sender
{
    BRDeviceInfoSettingRequest *request = (BRDeviceInfoSettingRequest *)[BRDeviceInfoSettingRequest request];
    [self.sensorsDevice sendMessage:request];
}

- (IBAction)queryServicesButton:(id)sender
{
//	[self performSelectorInBackground:@selector(ya) withObject:nil];
	
//	BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:BRServiceIDPedometer];
//	[self.sensorsDevice sendMessage:request];
	
	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDFreeFall
                                                                                        mode:BRServiceSubscriptionModePeriodic
                                                                                      period:1000];
	[self.sensorsDevice sendMessage:message];

	
//    for (int i = 0; i <= BRServiceIDGyroCal; i++) {
//        if (i==1) continue;
//        
//		BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:i];
//		[self.sensorsDevice sendMessage:request];
//    }
}

//- (void)ya
//{
//	for (;;) {
//		BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:BRServiceIDOrientationTracking];
//		[self.sensorsDevice sendMessage:request];
//		[NSThread sleepForTimeInterval:.2];
//
//	}
//}

- (IBAction)subscribeToServicesButton:(id)sender
{
    BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDTaps
                                                                                        mode:BRServiceSubscriptionModeOnChange
                                                                                      period:0];
    [self.sensorsDevice sendMessage:message];
    
//    for (int i = 0; i <= BRServiceIDGyroCal; i++) {
//        if (i==1) continue;
//		if (i==BRServiceIDOrientationTracking) continue;
//        
//        BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:i
//                                                                                            mode:BRServiceSubscriptionModeOnChange
//                                                                                          period:0];
//        [self.sensorsDevice sendMessage:message];
//    }
}

- (IBAction)unsubscribeFromServicesButton:(id)sender
{
    BRCalibratePedometerServiceCommand *cal = (BRCalibratePedometerServiceCommand *)[BRCalibratePedometerServiceCommand command];
    [self.device sendMessage:cal];
    
    for (int i = 0; i <= BRServiceIDGyroCal; i++) {
        if (i==1) continue;
        
        BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:i
                                                                                            mode:BRServiceSubscriptionModeOff
                                                                                          period:0];
        [self.sensorsDevice sendMessage:message];
    }
}

- (void)enableUI
{
    [self.closeConnectionButton setEnabled:YES];
    [self.queryWearingStateButton setEnabled:YES];
    [self.querySignalStrengthButton setEnabled:YES];
    [self.queryDeviceInfoButton setEnabled:YES];
    [self.querySubscribeToServicesButton setEnabled:YES];
    [self.queryUnsubscriberFromServicesButton setEnabled:YES];
    [self.queryQueryServicesButton setEnabled:YES];
    [self.subscribeToSignalStrengthButton setEnabled:YES];
}

- (void)disableUI
{
    [self.closeConnectionButton setEnabled:NO];
    [self.queryWearingStateButton setEnabled:NO];
    [self.querySignalStrengthButton setEnabled:NO];
    [self.queryDeviceInfoButton setEnabled:NO];
    [self.querySubscribeToServicesButton setEnabled:NO];
    [self.queryUnsubscriberFromServicesButton setEnabled:NO];
    [self.queryQueryServicesButton setEnabled:NO];
    [self.subscribeToSignalStrengthButton setEnabled:NO];
    self.connectedTextField.stringValue = @"No";
    self.wearingStateTextField.stringValue = @"-";
    self.signalStrengthTextField.stringValue = @"-";
    [self.headingIndicator setDoubleValue:-180];
    [self.pitchIndicator setDoubleValue:-90];
    [self.rollIndicator setDoubleValue:-90];
    self.freeFallTextField.stringValue = @"-";
    self.tapsTextField.stringValue = @"-";
    self.pedometerTextField.stringValue = @"-";
    self.gyroCalTextField.stringValue = @"-";
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
    NSLog(@"BRDeviceDidConnect: %@", device);
    
    self.connectedTextField.stringValue = @"Yeahh boi";
    [self enableUI];
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
    NSLog(@"BRDeviceDidDisconnect: %@", device);
    
    [self disableUI];
	
	if (device == self.device) {
		self.device = nil;
		self.sensorsDevice = nil;
	}
	else if (device == self.sensorsDevice) {
		self.sensorsDevice = nil;
	}
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
    NSLog(@"BRDevice: %@ didFailConnectWithError: %d", device, ioBTError);
	
	if (device == self.device) {
		self.device = nil;
	}
	else if (device == self.sensorsDevice) {
		self.sensorsDevice = nil;
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
    NSLog(@"BRDevice: %@ didReceiveEvent: %@", device, event);

    if ([event isKindOfClass:[BRWearingStateEvent class]]) {
        BRWearingStateEvent *e = (BRWearingStateEvent *)event;
        self.wearingStateTextField.stringValue = (e.isBeingWorn ? @"Yes" : @"No");
    }
    else if ([event isKindOfClass:[BRSignalStrengthEvent class]]) {
        BRSignalStrengthEvent *e = (BRSignalStrengthEvent *)event;
        self.signalStrengthTextField.stringValue = [NSString stringWithFormat:@"%d", e.strength];
    }
    else if ([event isKindOfClass:[BROrientationTrackingEvent class]]) {
        BROrientationTrackingEvent *e = (BROrientationTrackingEvent *)event;
		BREulerAngles eulerAngles = BREulerAnglesFromQuaternion(e.quaternion);		
        [self.headingIndicator setDoubleValue:-eulerAngles.x];
        [self.pitchIndicator setDoubleValue:eulerAngles.y];
        [self.rollIndicator setDoubleValue:eulerAngles.z];
    }
    else if ([event isKindOfClass:[BRTapsEvent class]]) {
        BRTapsEvent *e = (BRTapsEvent *)event;
        if (e.count) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", e.count, NSStringFromTapDirection(e.direction)];
        else self.tapsTextField.stringValue = @"-";
    }
    else if ([event isKindOfClass:[BRFreeFallEvent class]]) {
        BRFreeFallEvent *e = (BRFreeFallEvent *)event;
        self.freeFallTextField.stringValue = (e.isInFreeFall ? @"Yes" : @"No");
    }
    else if ([event isKindOfClass:[BRPedometerEvent class]]) {
        BRPedometerEvent *e = (BRPedometerEvent *)event;
        self.pedometerTextField.stringValue = [NSString stringWithFormat:@"%d", e.steps];
    }
    else if ([event isKindOfClass:[BRGyroscopeCalStatusEvent class]]) {
        BRGyroscopeCalStatusEvent *e = (BRGyroscopeCalStatusEvent *)event;
        self.gyroCalTextField.stringValue = (e.isCalibrated ? @"Yes" : @"No");
    }
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResponse:(BRSettingResponse *)response
{
    NSLog(@"BRDevice: %@ didReceiveSettingResponse: %@", device, response);
    
    if ([response isKindOfClass:[BRWearingStateSettingResponse class]]) {
        BRWearingStateSettingResponse *r = (BRWearingStateSettingResponse *)response;
        self.wearingStateTextField.stringValue = (r.isBeingWorn ? @"Yes" : @"No");
    }
    else if ([response isKindOfClass:[BRSignalStrengthSettingResponse class]]) {
        BRSignalStrengthSettingResponse *r = (BRSignalStrengthSettingResponse *)response;
        self.signalStrengthTextField.stringValue = [NSString stringWithFormat:@"%d", r.strength];
    }
    else if ([response isKindOfClass:[BROrientationTrackingSettingResponse class]]) {
        BROrientationTrackingSettingResponse *r = (BROrientationTrackingSettingResponse *)response;
		BREulerAngles eulerAngles = BREulerAnglesFromQuaternion(r.quaternion);		
        [self.headingIndicator setDoubleValue:-eulerAngles.x];
        [self.pitchIndicator setDoubleValue:eulerAngles.y];
        [self.rollIndicator setDoubleValue:eulerAngles.z];
    }
    else if ([response isKindOfClass:[BRTapsSettingResponse class]]) {
        BRTapsSettingResponse *r = (BRTapsSettingResponse *)response;
        if (r.count) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", r.count, NSStringFromTapDirection(r.direction)];
        else self.tapsTextField.stringValue = @"-";
    }
    else if ([response isKindOfClass:[BRFreeFallSettingResponse class]]) {
        BRFreeFallSettingResponse *r = (BRFreeFallSettingResponse *)response;
        self.freeFallTextField.stringValue = (r.isInFreeFall ? @"Yes" : @"No");
    }
    else if ([response isKindOfClass:[BRPedometerSettingResponse class]]) {
        BRPedometerSettingResponse *r = (BRPedometerSettingResponse *)response;
        self.pedometerTextField.stringValue = [NSString stringWithFormat:@"%d", r.steps];
    }
    else if ([response isKindOfClass:[BRGyroscopeCalStatusSettingResponse class]]) {
        BRGyroscopeCalStatusSettingResponse *r = (BRGyroscopeCalStatusSettingResponse *)response;
        self.gyroCalTextField.stringValue = (r.isCalibrated ? @"Yes" : @"No");
    }
}

- (void)BRDevice:(BRDevice *)device didRaiseException:(BRException *)exception
{
    NSLog(@"BRDevice: %@ didRaiseException: %@", device, exception);
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
    NSString *hexString = [data hexStringWithSpaceEvery:2];
    NSLog(@"--> %@", hexString);
    self.dataTextField.stringValue = [NSString stringWithFormat:@"--> %@", hexString];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
    NSString *hexString = [data hexStringWithSpaceEvery:2];
    NSLog(@"<-- %@", hexString);
    self.dataTextField.stringValue = [NSString stringWithFormat:@"<-- %@", hexString];
}

#pragma mark - NSWindowController

- (id)init
{
	if (self = [super initWithWindowNibName:@"MainWindow.xib"]) {
		return self;
	}
	return nil;
}

- (NSString *)windowNibName
{
    return @"MainWindow";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self disableUI];
    
    NSArray *devices = [PLTDevice availableDevices];
    NSLog(@"Available devices: %@", devices);
 }

@end
