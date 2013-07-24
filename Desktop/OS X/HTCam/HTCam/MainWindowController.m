//
//  MainWindowController.m
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "MainWindowController.h"
#import "AppDelegate.h"
#import "PLTLog.h"
#import "SettingsWindowController.h"
#import "HTDemoController.h"


NSString *const PLTHTCamNotificationLogMessage =		@"PLTHTCamNotificationLogMessage";
NSString *const PLTHTCamNotificationKeyLogMessage =		@"PLTHTCamNotificationKeyLogMessage";


@interface MainWindowController () <HTDemoControllerDelegate>

- (void)log:(NSString *)text, ...;
- (void)logMessageNotification:(NSNotification *)note;
- (void)setDemoStarted:(BOOL)started;
- (void)setActiveCam:(HTCam)cam;

@property (nonatomic, retain) NSImage *startImage;
@property (nonatomic, retain) NSImage *stopImage;
@property (nonatomic, retain) NSImage *inactiveCamFrame;
@property (nonatomic, retain) NSImage *activeCamFrame;

@end


@implementation MainWindowController

#pragma mark - Private

- (void)log:(NSString *)text, ...
{
	va_list list;
	va_start(list, text);
    NSString *message = [[NSString alloc] initWithFormat:text arguments:list];
	va_end(list);
	NSLog(@"%@", message);
	self.logTextView.string = [NSString stringWithFormat:@"%@%@%@",
							   self.logTextView.string, ([self.logTextView.string length] ? @"\n" : @""), message];
}

- (void)logMessageNotification:(NSNotification *)note
{
	[self log:[note userInfo][PLTHTCamNotificationKeyLogMessage]];
}

- (void)setDemoStarted:(BOOL)started
{
	NSLog(@"setDemoStarted: %@", (started ? @"YES" : @"NO"));
	
	if (started) {
		[self.startStopToolbarItem setLabel:@"Stop"];
		[self.startStopToolbarItem setImage:self.stopImage];
	}
	else {
		[self.startStopToolbarItem setLabel:@"Start"];
		[self.startStopToolbarItem setImage:self.startImage];
	}
}

- (void)setActiveCam:(HTCam)cam
{
	//NSLog(@"setActiveCam: %d", cam);
	
	self.cam1ImageView.image = self.inactiveCamFrame;
	self.cam2ImageView.image = self.inactiveCamFrame;
	self.cam3ImageView.image = self.inactiveCamFrame;
	
	NSImageView *imageView;
	
	switch (cam) {
		case HTCamNone:
			break;
		case HTCam1:
			imageView = self.cam1ImageView;
			break;
		case HTCam2:
			imageView = self.cam2ImageView;
			break;
		case HTCam3:
			imageView = self.cam3ImageView;
			break;
	}
	
	imageView.image = self.activeCamFrame;
}

#pragma mark - IBActions

- (IBAction)startStopButton:(id)sender
{
	NSLog(@"startStopButton:");
	
	HTDemoController *dc = [HTDemoController sharedController];
	BOOL isStarted = dc.isStarted;
	if (isStarted) {
		[dc stopDemo];
	}
	else {
		[dc startDemo];
	}
	[self setDemoStarted:dc.isStarted];
}

- (IBAction)settingsButton:(id)sender
{
	NSLog(@"settingsButton:");
	[((AppDelegate *)[NSApp delegate]).settingsWindowController showWindow:self];
}

#pragma mark - HTDemoControllerDelegate

- (void)HTDemoControllerDidStart:(HTDemoController *)controller
{
	NSLog(@"HTDemoControllerDidStart:");
}

- (void)HTDemoControllerDidStop:(HTDemoController *)controller
{
	NSLog(@"HTDemoControllerDidStop:");
	[self setActiveCam:HTCamNone];
}

- (void)HTDemoController:(HTDemoController *)controller changedActiveCam:(HTCam)cam
{
	NSLog(@"HTDemoController:changedActiveCam: %d", cam);
	
	[self setActiveCam:cam];
}

#pragma mark - NSNibAwakening

- (void)awakeFromNib
{
	[[self window] center];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logMessageNotification:) name:PLTHTCamNotificationLogMessage object:nil];
}

#pragma mark - NSWindowController

- (void)showWindow:(id)sender
{	
	[self setDemoStarted:NO];
	[super showWindow:sender];
}

#pragma mark - NSObject

- (id)init
{
	self = [super init];
	
	self.startImage = [NSImage imageNamed:@"camera_icon_off"];
	self.stopImage = [NSImage imageNamed:@"camera_icon_on"];
	self.inactiveCamFrame = [NSImage imageNamed:@"camstatus_inactive"];
	self.activeCamFrame = [NSImage imageNamed:@"camstatus_active"];
	[[HTDemoController sharedController] setDelegate:self];
	
	return self;
}

@end
