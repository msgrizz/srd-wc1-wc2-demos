//
//  VideoSwitchController
//  HTCam
//
//  Created by Davis, Morgan on 7/17/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "VideoSwitchController.h"
#import "MainWindowController.h"


#define FAKE_SWITCH					NO

#define CONNECT_SCRIPT_PATH			[[NSBundle mainBundle] pathForResource:@"Connect" ofType:@"scpt"]
#define DISCONNECT_SCRIPT_PATH		[[NSBundle mainBundle] pathForResource:@"Disconnect" ofType:@"scpt"]
#define ACTIVATE_CAM_1_SCRIPT_PATH	[[NSBundle mainBundle] pathForResource:@"ActivateCam1" ofType:@"scpt"]
#define ACTIVATE_CAM_2_SCRIPT_PATH	[[NSBundle mainBundle] pathForResource:@"ActivateCam2" ofType:@"scpt"]
#define ACTIVATE_CAM_3_SCRIPT_PATH	[[NSBundle mainBundle] pathForResource:@"ActivateCam3" ofType:@"scpt"]
#define ACTIVATE_AUX_SCRIPT_PATH	[[NSBundle mainBundle] pathForResource:@"ActivateAux" ofType:@"scpt"]


@interface VideoSwitchController ()

- (void)log:(NSString *)text, ...;
- (BOOL)killTerminal;
- (void)launchTerminal;
- (void)waitForTerminalQuit;
- (void)waitForTerminalLaunch;
- (void)_openConnection;

@property (nonatomic, retain) NSAppleScript *connectScript;
@property (nonatomic, retain) NSAppleScript *disconnectScript;
@property (nonatomic, retain) NSAppleScript *activateCam1Script;
@property (nonatomic, retain) NSAppleScript *activateCam2Script;
@property (nonatomic, retain) NSAppleScript *activateCam3Script;
//@property (nonatomic, retain) NSAppleScript *activateAuxScript;
@property (nonatomic, assign) HTCam activeCam;

@end


@implementation VideoSwitchController

#pragma mark - Public

+ (VideoSwitchController *)sharedController
{
	static VideoSwitchController *controller = nil;
	if (!controller) controller = [[VideoSwitchController alloc] init];
	return controller;
}

- (void)openConnection
{
	[self log:@"Opening video switch serial connection..."];
	
//	if ([self killTerminal]) {
//		[self waitForTerminalLaunch];
//	}
//	else {
//		[self launchTerminal];
//	}
	
	[self _openConnection];
}

- (void)closeConnection
{
	// uses AppleScript to actually close the switch connection in the serial terminal
	
	[self log:@"Closing video switch serial connection..."];
	
	NSDictionary *errInfo;
	[self.disconnectScript executeAndReturnError:&errInfo];
	if (errInfo) {
		[self log:@"Error closing serial connection: %@", errInfo];
	}
	else {
		[self log:@"Closed."];
	}
	self.isConncetionOpen = NO;
}

- (void)activateCam:(HTCam)cam
{
	// uses AppleScript to actually send a command to the serial terminal
	
	if (self.isConncetionOpen) {
		if (self.activeCam != cam) {
			[self log:@"Activating camera %d...", cam];
			
			NSAppleScript *script = nil;
			switch (cam) {
				case HTCam1:
					script = self.activateCam1Script;
					break;
				case HTCam2:
					script = self.activateCam2Script;
					break;
				case HTCam3:
					script = self.activateCam3Script;
					break;
//				default:
//					script = self.activateAuxScript;
//					break;
			}
			
//#warning !!!!!!!!!!!!!!!!!!! DEBUG ONLY !!!!!!!!!!!!!!!!!!!!!!
//			return;
			
			self.activeCam = cam;
			
			if (FAKE_SWITCH) {
				DLog(@"(Fake switching)");
				return;
			}
			
			NSDictionary *errInfo;
			[script executeAndReturnError:&errInfo];
			if (errInfo) {
				[self log:@"Error executing script: %@", errInfo];
			}
		}
	}
	else {
		if (cam != HTCamNone) DLog(@"Can't activate camera %d. Video switch connection not open.", cam);
	}
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

- (BOOL)killTerminal
{
	// searches open processes for "CoolTerm". if found kills it and returns YES. otherwise return NO.
	
	NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
	for (NSRunningApplication *app in runningApps) {
		if ([app.bundleIdentifier isEqualToString:@"org.the-meiers.coolterm"]) {
			[self log:@"Killing CoolTerm..."];
			[app forceTerminate]; // fails to check return value
			return YES;
		}
	}
	return NO;
}

- (void)launchTerminal
{
	// launches our term config file from bundle resources
	
	NSString *appPath = [[NSBundle mainBundle] pathForResource:@"CoolTerm" ofType:@"app"];
	NSURL *appURL = [NSURL fileURLWithPath:appPath];
	NSError *err;
	[self log:@"Launching CoolTerm..."];
	[[NSWorkspace sharedWorkspace] launchApplicationAtURL:appURL options:nilHandleErr configuration:nil error:&err];
	if (!err) {
		[self waitForTerminalLaunch];
	}
	else {
		[self log:@"Error launching terminal app: %@", err];
	}
}

- (void)waitForTerminalQuit
{
	DLog(@"Waiting for CoolTerm to quit...");
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidTerminateApplicationNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
		[self log:@"CoolTerm terminated."];
		[self waitForTerminalLaunch];
		[self launchTerminal];
	}];
}

- (void)waitForTerminalLaunch
{
	DLog(@"Waiting for CoolTerm to launch...");
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidLaunchApplicationNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
		[self log:@"CoolTerm launched."];
		[self _openConnection];
	}];
}

- (void)_openConnection
{
	// uses AppleScript to actually open the switch connection in the serial terminal
	
	NSDictionary *errInfo;
	[self.connectScript executeAndReturnError:&errInfo];
	if (errInfo) {
		[self log:@"Error opening serial connection! %@", errInfo];
		self.isConncetionOpen = NO;
	}
	else {
		[self log:@"Connection open."];
		self.isConncetionOpen = YES;
	}
}

#pragma mark - NSObject

- (id)init
{
	self = [super init];
	
	self.connectScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:CONNECT_SCRIPT_PATH] error:nil];
	self.disconnectScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:DISCONNECT_SCRIPT_PATH] error:nil];
	self.activateCam1Script= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:ACTIVATE_CAM_1_SCRIPT_PATH] error:nil];
	self.activateCam2Script= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:ACTIVATE_CAM_2_SCRIPT_PATH] error:nil];
	self.activateCam3Script= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:ACTIVATE_CAM_3_SCRIPT_PATH] error:nil];
	//self.activateAuxScript= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:ACTIVATE_AUX_SCRIPT_PATH] error:nil];
	[self.connectScript compileAndReturnError:nil];
	[self.disconnectScript compileAndReturnError:nil];
	[self.activateCam1Script compileAndReturnError:nil];
	[self.activateCam2Script compileAndReturnError:nil];
	[self.activateCam3Script compileAndReturnError:nil];
	//[self.activateAuxScript compileAndReturnError:nil];
	
	return self;
}

- (void)dealloc
{
	if (self.isConncetionOpen) {
		[self closeConnection];
	}
}

@end
