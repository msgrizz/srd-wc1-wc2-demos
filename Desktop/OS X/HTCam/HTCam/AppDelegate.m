//
//  AppDelegate.m
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "PLTContextServer.h"
#import "VideoSwitchController.h"
#import "SettingsWindowController.h"
#import "PLTHeadsetManager.h"


NSString *const PLTDefaultsKeyDefaultsVersion =								@"DefaultsVersion";
NSString *const PLTDefaultsKeyContextServerAddress =                        @"ContextServerAddress";
NSString *const PLTDefaultsKeyContextServerPort =                           @"ContextServerPort";
NSString *const PLTDefaultsKeyContextServerUsername =                       @"ContextServerUsername";
NSString *const PLTDefaultsKeyContextServerPassword =                       @"ContextServerPassword";
NSString *const PLTDefaultsKeyContextServerAutoConnect =                    @"ContextServerAutoConnect";
NSString *const PLTDefaultsKeyVideoSwitchAutoConnect =						@"VideoSwitchAutoConnect";
NSString *const PLTDefaultsKeyCam1Location =								@"Cam1Location";
NSString *const PLTDefaultsKeyCam2Location =								@"Cam2Location";
NSString *const PLTDefaultsKeyCam3Location =								@"Cam3Location";
NSString *const PLTDefaultsKeyCamSwitchDelay =								@"CamSwitchDelay";


@interface AppDelegate () <PLTContextServerDelegate>

- (void)log:(NSString *)text, ...;
- (void)registerDefaults;
- (void)checkAutoConnectToContextServer;
- (void)checkAutoConnectToVideoSwitch;

@end


@implementation AppDelegate

#pragma mark - Public

- (void)connectToContextServer
{
	NSString *address = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerAddress];
    NSString *port = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPort];
    NSString *username = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerUsername];
    NSString *password = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPassword];
    
	[self log:@"Connecting to Context Server at %@:%@...", address, port];
	
    NSMutableString *urlstring = [NSString stringWithFormat:@"ws://%@:%@/context-server/context-websocket", address, port];
	PLTContextServer *server = [PLTContextServer sharedContextServerWithURL:urlstring
																   username:username
																   password:password
																  protocols:@[@"plt-device"]];
	[server openConnection];
}

- (BOOL)hasServerCredentials
{
	NSString *username = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerUsername];
	NSString *password = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPassword];
	
	if ([username length] && [password length]) return YES;
	return NO;
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

- (void)registerDefaults
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	if (![DEFAULTS boolForKey:@"SettingsAreInitialized"]) {
		DLog(@"Initializing defaults.");
        // if this is the first time the application has run, read
        // the default application settings from PLTAppSettings.plist
        NSString *settingsFilePath = [mainBundle pathForResource:@"AppSettings" ofType:@"plist"];
        NSDictionary *defaultSettings = [NSDictionary dictionaryWithContentsOfFile:settingsFilePath];
        [DEFAULTS registerDefaults:defaultSettings];
    }
	
	// do version upgrade stuff here in the future
	NSString *previousVersion = [DEFAULTS objectForKey:PLTDefaultsKeyDefaultsVersion];
	DLog(@"Previously used version: %@",previousVersion);
	[DEFAULTS setObject:[[mainBundle infoDictionary] objectForKey:@"CFBundleVersion"] forKey:PLTDefaultsKeyDefaultsVersion];
	[DEFAULTS synchronize];
}

- (void)checkAutoConnectToContextServer
{
	DLog(@"checkAutoConnectToContextServer");
	
	BOOL autoConnect = [DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoConnect];
	if ([self hasServerCredentials]) {
		if (autoConnect && !CLIENT_AUTHENTICATED) {
			[[PLTContextServer sharedContextServer] addDelegate:self];
			[self connectToContextServer];
		}
	}
}

- (void)checkAutoConnectToVideoSwitch
{
	if ([[DEFAULTS objectForKey:PLTDefaultsKeyVideoSwitchAutoConnect] boolValue]) {
		[[VideoSwitchController sharedController] openConnection];
	}
}

#pragma mark - PLTContextServerDelegate

- (void)serverDidOpen:(PLTContextServer *)sender
{
	[self log:@"Connection open."];
}

- (void)server:(PLTContextServer *)sender didAuthenticate:(BOOL)authenticationWasSuccessful
{
	if (authenticationWasSuccessful) {
		[self log:@"Context Server connection authenticated."];
	}
	else {
		[self log:@"Context Server authentication failed."];
	}
}

- (void)server:(PLTContextServer *)sender didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
	if (code==0) {
		[self log:@"Context Server connection closed."];
	}
	else {
		[self log:@"Context Server connection closed with code %d. Reason: %@", code, reason];
	}
}

- (void)server:(PLTContextServer *)sender didFailWithError:(NSError *)error
{
	[self log:@"Context Server connection failed with error: %@", error];
}

- (BOOL)serverShouldTryToReconnect:(PLTContextServer *)sender
{
	if ([self hasServerCredentials]) {
		[self log:@"Attempting to reconnect to Context Server..."];
		return YES;
	}
	return NO;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self registerDefaults];
	[self.mainWindowController window];
	[[PLTContextServer sharedContextServer] addDelegate:self];
	[VideoSwitchController sharedController];
	[HTDemoController sharedController];
	self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:nil];
	[self.mainWindowController showWindow:self];
	[self checkAutoConnectToContextServer];
	[self checkAutoConnectToVideoSwitch];
	
	[[HTDemoController sharedController] stopDemo];
	
//	double delayInSeconds = 1.0;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[[VideoSwitchController sharedController] activateCam:HTCamAux];
//	});
}

@end
