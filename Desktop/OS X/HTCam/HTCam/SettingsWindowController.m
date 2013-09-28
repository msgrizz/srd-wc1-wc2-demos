//
//  SettingsWindowController.m
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SettingsWindowController.h"
#import "PLTContextServer.h"
#import "MainWindowController.h"
#import "AppDelegate.h"
#import "HTDemoController.h"
#import "PLTHeadsetManager.h"
#import "VideoSwitchController.h"


NSString *const PLTHTCamNotificationCamLocationChanged =		@"PLTHTCamNotificationCamLocationChanged";


@interface SettingsWindowController () <PLTContextServerDelegate, NSControlTextEditingDelegate>

- (void)setCSStatusConnected:(BOOL)connected;
- (void)setSwitchStatusConnected:(BOOL)connected;
- (void)camLocationChanged;
- (void)updateCamLocations;
- (void)updateCSSettings;
- (void)saveCSSettings;
- (void)updateSwitchSettings;
- (void)updateCamSwitchDelay;

@property (nonatomic, assign) CGPoint cam1Location;
@property (nonatomic, assign) CGPoint cam2Location;
@property (nonatomic, assign) CGPoint cam3Location;
@property (nonatomic, retain) NSColor *greenTextColor;
@property (nonatomic, retain) NSColor *redTextColor;

@end


@implementation SettingsWindowController

@synthesize cam1Location = _cam1Location;
@synthesize cam2Location = _cam2Location;
@synthesize cam3Location = _cam3Location;

#pragma mark - Private

- (void)log:(NSString *)text, ...
{
	va_list list;
	va_start(list, text);
    NSString *message = [[NSString alloc] initWithFormat:text arguments:list];
	va_end(list);
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTHTCamNotificationLogMessage object:nil userInfo:@{PLTHTCamNotificationKeyLogMessage: message}];
}

- (void)setCSStatusConnected:(BOOL)connected
{
	DLog(@"setCSStatusConnected: %@", (connected ? @"YES" : @"NO"));
	
	[self.csConnectDisconnectButton setEnabled:YES];
	[self.csConnectingSpinner stopAnimation:self];
	[self.csConnectingSpinner setHidden:YES];
	
	if (connected) {
		self.csStatusTextField.stringValue = @"Connected";
		self.csStatusTextField.textColor = self.greenTextColor;
		[self.csConnectDisconnectButton setTitle:@"Disconnect"];
		[self.csConnectingSpinner stopAnimation:self];
		[self.csConnectingSpinner setHidden:YES];
	}
	else {
		self.csStatusTextField.stringValue = @"Disconnected";
		self.csStatusTextField.textColor = self.redTextColor;
		[self.csConnectDisconnectButton setTitle:@"Connect"];
		[self.csConnectingSpinner startAnimation:self];
		[self.csConnectingSpinner setHidden:NO];
	}
}

- (void)setSwitchStatusConnected:(BOOL)connected
{
	DLog(@"setSwitchStatusConnected: %@", (connected ? @"YES" : @"NO"));
	
	if (connected) {
		self.switchStatusTextField.stringValue = @"Connected";
		self.switchStatusTextField.textColor = self.greenTextColor;
		[self.switchConnectDisconnectButton setEnabled:YES];
		[self.switchConnectDisconnectButton setTitle:@"Disconnect"];
	}
	else {
		self.switchStatusTextField.stringValue = @"Disconnected";
		self.switchStatusTextField.textColor = self.redTextColor;
		[self.switchConnectDisconnectButton setEnabled:YES];
		[self.switchConnectDisconnectButton setTitle:@"Connect"];
	}
}

- (void)camLocationChanged
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTHTCamNotificationCamLocationChanged object:nil userInfo:nil];
	[self updateCamLocations];
}

- (void)updateCamLocations
{
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam1Location]), &_cam1Location);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam2Location]), &_cam2Location);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([DEFAULTS objectForKey:PLTDefaultsKeyCam3Location]), &_cam3Location);
	self.cam1CalTextField.stringValue = [NSString stringWithFormat:@"(%ld, %ld)", lroundf(_cam1Location.x), lroundf(_cam1Location.y)];
	self.cam2CalTextField.stringValue = [NSString stringWithFormat:@"(%ld, %ld)", lroundf(_cam2Location.x), lroundf(_cam2Location.y)];
	self.cam3CalTextField.stringValue = [NSString stringWithFormat:@"(%ld, %ld)", lroundf(_cam3Location.x), lroundf(_cam3Location.y)];
}

- (void)updateCSSettings
{
	self.csAddressTextField.stringValue = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerAddress];
	self.csPortTextField.stringValue = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPort];
	self.csUsernameTextField.stringValue = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerUsername];
	self.csPasswordTextField.stringValue = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPassword];
	self.csAutoConnectCheckbox.state = ([[DEFAULTS objectForKey:PLTDefaultsKeyContextServerAutoConnect] boolValue] ? NSOnState : NSOffState);
}

- (void)saveCSSettings
{
	[DEFAULTS setObject:self.csAddressTextField.stringValue forKey:PLTDefaultsKeyContextServerAddress];
	[DEFAULTS setObject:self.csPortTextField.stringValue forKey:PLTDefaultsKeyContextServerPort];
	[DEFAULTS setObject:self.csUsernameTextField.stringValue forKey:PLTDefaultsKeyContextServerUsername];
	[DEFAULTS setObject:self.csPasswordTextField.stringValue forKey:PLTDefaultsKeyContextServerPassword];
	[DEFAULTS setObject:@(self.csAutoConnectCheckbox.state == NSOnState) forKey:PLTDefaultsKeyContextServerAutoConnect];
}

- (void)updateSwitchSettings
{
	self.switchAutoConnectCheckbox.state = ([[DEFAULTS objectForKey:PLTDefaultsKeyVideoSwitchAutoConnect] boolValue] ? NSOnState : NSOffState);
}

- (void)updateCamSwitchDelay
{
	float delay = [DEFAULTS floatForKey:PLTDefaultsKeyCamSwitchDelay];
	self.camSwitchDelaySlider.floatValue = delay;
	self.camSwitchDelayTextField.stringValue = [NSString stringWithFormat:@"%.1f seconds", delay];
}

#pragma mark - IBActions

- (IBAction)csConnectDisconnectButton:(id)sender
{
	DLog(@"csConnectDisconnectButton:");
	
	PLTContextServer *cs = [PLTContextServer sharedContextServer];
	if (cs.state >= PLT_CONTEXT_SERVER_AUTHENTICATED) {
		[[PLTContextServer sharedContextServer] closeConnection];
	}
	else {
		[self.csConnectDisconnectButton setEnabled:NO];
		[self.csConnectingSpinner startAnimation:self];
		[self.csConnectingSpinner setHidden:NO];
		[(AppDelegate *)[[NSApplication sharedApplication] delegate] connectToContextServer];
	}
}

- (IBAction)switchConnectDisconnectButton:(id)sender
{
	DLog(@"switchConnectDisconnectButton:");
	
	VideoSwitchController *vsm = [VideoSwitchController sharedController];
	if (vsm.isConncetionOpen) {
		[vsm closeConnection];
		[self setSwitchStatusConnected:NO];
	}
	else {
		[vsm openConnection];
		[self setSwitchStatusConnected:YES];
	}
}

- (IBAction)calCam1Button:(id)sender
{
	DLog(@"calCam1Button:");
	NSData *rotationData = ([HTDemoController sharedController].latestHeadsetInfo)[PLTHeadsetInfoKeyRotationVectorData];
	Vec3 rotation;
	[rotationData getBytes:&rotation length:[rotationData length]];
	CGPoint location = CGPointMake(rotation.x, rotation.y);
	[self log:@"Setting Cam 1 location to %@.", NSStringFromPoint(location)];
	NSDictionary *locationDict = (__bridge NSDictionary *)(CGPointCreateDictionaryRepresentation(location));
	[DEFAULTS setObject:locationDict forKey:PLTDefaultsKeyCam1Location];
	[self camLocationChanged];
}

- (IBAction)calCam2Button:(id)sender
{
	DLog(@"calCam2Button:");
	NSData *rotationData = ([HTDemoController sharedController].latestHeadsetInfo)[PLTHeadsetInfoKeyRotationVectorData];
	Vec3 rotation;
	[rotationData getBytes:&rotation length:[rotationData length]];
	CGPoint location = CGPointMake(rotation.x, rotation.y);
	[self log:@"Setting Cam 2 location to %@.", NSStringFromPoint(location)];
	NSDictionary *locationDict = (__bridge NSDictionary *)(CGPointCreateDictionaryRepresentation(location));
	[DEFAULTS setObject:locationDict forKey:PLTDefaultsKeyCam2Location];
	[self camLocationChanged];
}

- (IBAction)calCam3Button:(id)sender
{
	DLog(@"calCam3Button:");
	NSData *rotationData = ([HTDemoController sharedController].latestHeadsetInfo)[PLTHeadsetInfoKeyRotationVectorData];
	Vec3 rotation;
	[rotationData getBytes:&rotation length:[rotationData length]];
	CGPoint location = CGPointMake(rotation.x, rotation.y);
	[self log:@"Setting Cam 3 location to %@.", NSStringFromPoint(location)];
	NSDictionary *locationDict = (__bridge NSDictionary *)(CGPointCreateDictionaryRepresentation(location));
	[DEFAULTS setObject:locationDict forKey:PLTDefaultsKeyCam3Location];
	[self camLocationChanged];
}

- (IBAction)csAutoConnectCheckbox:(id)sender
{
	DLog(@"csAutoConnectCheckbox:");
	[self saveCSSettings];
}

- (IBAction)switchAutoConnectCheckbox:(id)sender
{
	DLog(@"switchAutoConnectCheckbox:");
	[DEFAULTS setBool:(self.switchAutoConnectCheckbox.state == NSOnState) forKey:PLTDefaultsKeyVideoSwitchAutoConnect];
}

- (IBAction)camSwitchDelaySlider:(id)sender
{
	float delay = [sender floatValue];
	[DEFAULTS setFloat:delay forKey:PLTDefaultsKeyCamSwitchDelay];
	[self updateCamSwitchDelay];
}

#pragma mark - PLTContextServerDelegate

- (void)serverDidOpen:(PLTContextServer *)sender
{
    //[self log:@"Context Server connection opened."];
}

- (void)server:(PLTContextServer *)sender didAuthenticate:(BOOL)authenticationWasSuccessful
{
	DLog(@"server:didAuthenticate: %@", (authenticationWasSuccessful ? @"YES" : @"NO"));
	
	[self setCSStatusConnected:authenticationWasSuccessful];
	
    if (authenticationWasSuccessful) {
		//[self log:@"Context Server client authenticated."];
	}
	else {
        //[self log:@"Context Server client authentication failed."];
        
		//		if (!self.authFailureAlertView) {
		//			self.authFailureAlertView = [[UIAlertView alloc] initWithTitle:@"Authentication Failed"
		//																   message:@"Please check your username and password in \"Server Settings.\""
		//																  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//			self.authFailureAlertView.tag = PLTAlertViewTagAuthenticationFailed;
		//			[self.authFailureAlertView show];
		//		}
    }
	
	//[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)server:(PLTContextServer *)sender didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    //[self log:@"Context Server connection closed: %@", reason];
	[self setCSStatusConnected:NO];
	[self.csConnectingSpinner stopAnimation:self];
	[self.csConnectingSpinner setHidden:YES];
}

- (void)server:(PLTContextServer *)sender didFailWithError:(NSError *)error
{
    //[self log:@"Context Server connection failed with error: %@", [error description]];
	[self setCSStatusConnected:NO];
	[self.csConnectingSpinner stopAnimation:self];
	[self.csConnectingSpinner setHidden:YES];
}

#pragma mark - NSControlTextEditingDelegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	DLog(@"control:textShouldEndEditing:");
	[self saveCSSettings];
	return YES;
}

#pragma mark - NSWindowController

- (void)showWindow:(id)sender
{
	//[[self window] center];
	[super showWindow:sender];
}

- (void)windowDidLoad
{
	[[PLTContextServer sharedContextServer] addDelegate:self];
	
	NSInteger csState = [PLTContextServer sharedContextServer].state;
	[self setCSStatusConnected:(csState >= PLT_CONTEXT_SERVER_AUTHENTICATED)];
	if ((csState == PLT_CONTEXT_SERVER_OPENING) || (csState == PLT_CONTEXT_SERVER_OPEN) || (csState == PLT_CONTEXT_SERVER_AUTHENTICATING)) {
		[self.csConnectDisconnectButton setEnabled:NO];
		[self.csConnectingSpinner startAnimation:self];
		[self.csConnectingSpinner setHidden:NO];
	}
	else {
		[self.csConnectingSpinner setHidden:YES];
	}
	[self setSwitchStatusConnected:[VideoSwitchController sharedController].isConncetionOpen];
	[self updateCamLocations];
	
	[self updateCSSettings];
	[self updateSwitchSettings];
	[self updateCamSwitchDelay];
	
	[[self window] center];
	
	[super windowDidLoad];
}

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:@"SettingsWindow"];
    if (self) {
		self.greenTextColor = [NSColor colorWithCalibratedRed:0 green:.5 blue:0 alpha:1];
		self.redTextColor = [NSColor colorWithCalibratedRed:.5 green:0 blue:0 alpha:1];
    }
    
    return self;
}

@end
