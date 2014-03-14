//
//  MainWindowController.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MainWindowController.h"




#import "BRDevice.h"
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

#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
#import <IOBluetooth/IOBluetooth.h>




@interface MainWindowController () <BRDeviceDelegate>

- (IBAction)openConnectionButton:(id)sender;
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
@property(nonatomic,retain) BRDevice *sensorsDevice;

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
    NSArray *devices = [PLTDevice availableDevices];
    if ([devices count]) {
        NSString *macString = ((PLTDevice *)devices[0]).bluetoothDevice.addressString;
        //NSString *macString = @"48:C1:AC:9B:DA:6F"; // WC1 fresh
        //NSString *macString = @"48:C1:AC:9B:DB:68"; // WC1 stale
        self.device = [BRDevice deviceWithAddress:macString]; 
        self.device.delegate = self;
        [self.device openConnection];
    }
}

- (IBAction)subscribeToServicesButton:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 1; i <= BRServiceIDGyroCal; i++) {
            if (i==1) continue;
            BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:i
                                                                                                mode:BRServiceSubscriptionModeOnChange
                                                                                              period:0];
            [self.device sendMessage:message];
            [NSThread sleepForTimeInterval:.1];
        }
    });
}

- (IBAction)unsubscribeFromServicesButton:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i <= BRServiceIDGyroCal; i++) {
            if (i==1) continue;
            BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:i
                                                                                                mode:BRServiceSubscriptionModeOff
                                                                                              period:0];
            [self.device sendMessage:message];
            [NSThread sleepForTimeInterval:.1];
        }
    });
}

- (IBAction)queryDeviceInfoButton:(id)sender
{
    BRDeviceInfoSettingRequest *request = (BRDeviceInfoSettingRequest *)[BRDeviceInfoSettingRequest request];
    [self.device sendMessage:request];
}

- (IBAction)queryWearingStateButton:(id)sender
{
    BRWearingStateSettingRequest *request = (BRWearingStateSettingRequest *)[BRWearingStateSettingRequest request];
    [self.device sendMessage:request];
}

- (IBAction)querySignalStrengthButton:(id)sender
{
//    BRSignalStrengthSettingRequest *request = (BRSignalStrengthSettingRequest *)[BRSignalStrengthSettingRequest request];
//    [self.device sendMessage:request];
    
    BRCalibratePedometerServiceCommand *command = [BRCalibratePedometerServiceCommand command];
    [self.device sendMessage:command];
    
//    BRServiceCalibrationSettingRequest *request = [BRServiceCalibrationSettingRequest requestWithServiceID:BRServiceIDOrientationTracking];
//    [self.device sendMessage:request];
}

- (IBAction)queryServicesButton:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i <= BRServiceIDGyroCal; i++) {
            if (i==1) continue;
            BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:i];
            [self.device sendMessage:request];
            [NSThread sleepForTimeInterval:1.0];
        }
    });
}

- (IBAction)subscribeToSignalStrengthButton:(id)sender
{
    BRSubscribeToSignalStrengthCommand *command = [BRSubscribeToSignalStrengthCommand commandWithSubscription:YES];
    [self.device sendMessage:command];
}

- (void)enableUI
{
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

- (void)BRDeviceDidConnectToHTDevice:(BRDevice *)device
{
    NSLog(@"BRDeviceDidConnectToHTDevice:");
    
    self.connectedTextField.stringValue = @"Yeahh boi";
    [self enableUI];
}

- (void)BRDeviceDidDisconnectFromHTDevice:(BRDevice *)device
{
    NSLog(@"BRDeviceDidDisconnectFromHTDevice:");
    
    [self disableUI];
}

- (void)BRDevice:(BRDevice *)device didFailConnectToHTDeviceWithError:(int)ioBTError
{
    NSLog(@"BRDevice:didFailConnectToHTDeviceWithError: %d", ioBTError);
}

- (void)BRDevice:(BRDevice *)device didReceiveMetadata:(BRMetadata *)metadata
{
    NSLog(@"BRDevice:didReceiveMetadata: %@", metadata);
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
    NSLog(@"BRDevice:didReceiveEvent: %@", event);
    
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
        [self.headingIndicator setDoubleValue:-e.rawEulerAngles.x];
        [self.pitchIndicator setDoubleValue:e.rawEulerAngles.y];
        [self.rollIndicator setDoubleValue:e.rawEulerAngles.z];
    }
    else if ([event isKindOfClass:[BRTapsEvent class]]) {
        BRTapsEvent *e = (BRTapsEvent *)event;
        if (e.taps) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", e.taps, NSStringFromTapDirection(e.direction)];
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
    NSLog(@"BRDevice:didReceiveSettingResponse: %@", response);
    
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
        [self.headingIndicator setDoubleValue:-r.rawEulerAngles.x];
        [self.pitchIndicator setDoubleValue:r.rawEulerAngles.y];
        [self.rollIndicator setDoubleValue:r.rawEulerAngles.z];
    }
    else if ([response isKindOfClass:[BRTapsSettingResponse class]]) {
        BRTapsSettingResponse *r = (BRTapsSettingResponse *)response;
        if (r.taps) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", r.taps, NSStringFromTapDirection(r.direction)];
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
    NSLog(@"BRDevice:didRaiseException: %@", exception);
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



//- (void)BRDevice:(BRDevice *)device didDiscoverAdjacentDevice:(BRDevice *)newDevice
//{
//    NSLog(@"BRDevice:didDiscoverAdjacentDevice: %@", newDevice);
//}

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
