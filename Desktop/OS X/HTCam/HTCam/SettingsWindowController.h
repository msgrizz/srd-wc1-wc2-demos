//
//  SettingsWindowController.h
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString *const PLTHTCamNotificationCamLocationChanged;


@interface SettingsWindowController : NSWindowController

- (IBAction)csConnectDisconnectButton:(id)sender;
- (IBAction)switchConnectDisconnectButton:(id)sender;
- (IBAction)calCam1Button:(id)sender;
- (IBAction)calCam2Button:(id)sender;
- (IBAction)calCam3Button:(id)sender;
- (IBAction)csAutoConnectCheckbox:(id)sender;
- (IBAction)switchAutoConnectCheckbox:(id)sender;
- (IBAction)camSwitchDelaySlider:(id)sender;

@property (nonatomic, retain) IBOutlet NSTextField *cam1CalTextField;
@property (nonatomic, retain) IBOutlet NSTextField *cam2CalTextField;
@property (nonatomic, retain) IBOutlet NSTextField *cam3CalTextField;
@property (nonatomic, retain) IBOutlet NSButton *csAutoConnectCheckbox;
@property (nonatomic, retain) IBOutlet NSButton *switchAutoConnectCheckbox;
@property (nonatomic, retain) IBOutlet NSTextField *csStatusTextField;
@property (nonatomic, retain) IBOutlet NSTextField *switchStatusTextField;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *csConnectingSpinner;
@property (nonatomic, retain) IBOutlet NSButton *csConnectDisconnectButton;
@property (nonatomic, retain) IBOutlet NSButton *switchConnectDisconnectButton;
@property (nonatomic, retain) IBOutlet NSTextField *csAddressTextField;
@property (nonatomic, retain) IBOutlet NSTextField *csPortTextField;
@property (nonatomic, retain) IBOutlet NSTextField *csUsernameTextField;
@property (nonatomic, retain) IBOutlet NSTextField *csPasswordTextField;
@property (nonatomic, retain) IBOutlet NSSlider *camSwitchDelaySlider;
@property (nonatomic, retain) IBOutlet NSTextField *camSwitchDelayTextField;

@end
