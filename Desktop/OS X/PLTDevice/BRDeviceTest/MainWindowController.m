//
//  MainWindowController.m
//  PLTDevice
//
//  Created by Davis, Morgan on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MainWindowController.h"




#import "BRDevice.h"
#import "BRMessage.h"
#import "BRSubscribeToServicesCommand.h"
#import "BROrientationTrackingEvent.h"
#import "BRQueryWearingStateSettingRequest.h"
#import "BRQuerySignalStrengthSettingRequest.h"
#import "BRSubscribeToSignalStrengthCommand.h"


@interface MainWindowController () <BRDeviceDelegate>

- (IBAction)openConnectionButton:(id)sender;
- (IBAction)subscribeToSensorsButton:(id)sender;
- (IBAction)unsubscribeFromSensorsButton:(id)sender;
- (IBAction)querySensorsButton:(id)sender;

@property(nonatomic,retain) BRDevice *device;

@end


@implementation MainWindowController

#pragma mark - Private

- (IBAction)openConnectionButton:(id)sender
{
    self.device = [BRDevice controllerWithDeviceAddress:@"48:C1:AC:9B:DA:6F"]; // WC1
    self.device.delegate = self;
    [self.device openConnection];
}

- (IBAction)subscribeToSensorsButton:(id)sender
{
    BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRServiceIDOrientationTracking
                                                                                          mode:BRServiceSubscriptionModeOnChange
                                                                                        period:0];
    [self.device sendMessage:message];
}

- (IBAction)unsubscribeFromSensorsButton:(id)sender
{
    
}

- (IBAction)querySensorsButton:(id)sender
{
    
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnectToHTDevice:(BRDevice *)device
{
    NSLog(@"BRDeviceDidConnectToHTDevice:");
}

- (void)BRDeviceDidDisconnectFromHTDevice:(BRDevice *)device
{
    NSLog(@"BRDeviceDidDisconnectFromHTDevice:");
}

- (void)BRDevice:(BRDevice *)device didFailConnectToHTDeviceWithError:(int)ioBTError
{
    NSLog(@"BRDevice:didFailConnectToHTDeviceWithError: %d", ioBTError);
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
    NSLog(@"BRDevice:didReceiveEvent: %@", event);
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
    
 }

@end
