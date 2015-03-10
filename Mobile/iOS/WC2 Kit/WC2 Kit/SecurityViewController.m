//
//  SecurityViewController.m
//  PLTSensor
//
//  Created by Morgan Davis on 12/10/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import "SecurityViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import "PLTDevice_Internal.h"
#import "PLTDeviceHelper.h"
#import "Reachability.h"
#import "SettingsViewController.h"
#import "PLTDevice_Internal.h"
#import "BRDevice.h"
#import "BRSubscribeToServicesCommand.h"
#import "BRSubscribedServiceDataEvent.h"
#import "SecurityHelper.h"


#define RELOCK_DELAY	30.0 // s
#define SENSOR_DEVICE	CONNECTED_DEVICE.brDevice.remoteDevices[@(5)]


typedef enum {
	PLTLockStateLocked,
	PLTLockStateUnlocked
} PLTLockState;


@interface SecurityViewController () <PLTDeviceSubscriber, PLTDeviceBRDevicePassthroughDelegate, SecurityHelperSignDelegate, NSURLConnectionDelegate>

- (IBAction)touchID:(id)sender;
- (IBAction)sign:(id)sender;
- (void)didGetUnlockVoiceCommand;
- (UIImage *)imageForAuthSuccess:(BOOL)flag;
- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;
- (BOOL)checkReachability;
- (void)deviceChanged:(NSNotification *)aNotification;
- (void)checReadyForVoiceCommand;
- (void)setLockState:(PLTLockState)state lockID:(NSString *)lockID;
- (void)startLockTimer;
- (void)stopLockTimer;
- (void)lockTimer:(NSTimer *)aTimer;
- (void)resetState;

@property(nonatomic,strong)	Reachability						*reachability;
@property(nonatomic,strong)	UIImageView							*reachabilityImageView;
@property(nonatomic,assign) BOOL								touchIDAuthenticated;
@property(nonatomic,assign) BOOL								fidoAuthenticated;
@property(nonatomic,assign) BOOL								unlocked;
@property(nonatomic,strong) NSURLConnection						*lockConnection;
@property(nonatomic,strong) NSTimer								*lockTimer;
@property(nonatomic,strong)	IBOutlet UIButton					*touchIDButton;
@property(nonatomic,strong)	IBOutlet UIButton					*fidoButton;
@property(nonatomic,strong)	IBOutlet UIActivityIndicatorView	*fidoStatusProgressView;
@property(nonatomic,strong)	IBOutlet UILabel					*fidoStatusLabel;
@property(nonatomic,strong)	IBOutlet UIImageView				*touchIDStatusImageView;
@property(nonatomic,strong)	IBOutlet UIImageView				*fidoStatusImageView;
@property(nonatomic,strong)	IBOutlet UILabel					*authStatusLabel;

@end


@implementation SecurityViewController

#pragma mark - Private

- (IBAction)touchID:(id)sender
{
	NSLog(@"touchID:");
	
	self.touchIDButton.enabled = NO;
	self.touchIDStatusImageView.image = nil;
	
	LAContext *lsContext = [[LAContext alloc] init];
	[lsContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
			  localizedReason:@"First Factor Authentication"
						reply:^(BOOL success, NSError *error) {
							int64_t delayInSeconds = .5;
							dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
							dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
								self.touchIDButton.enabled = YES;
								if (success) {
									NSLog(@"good!");
									self.touchIDAuthenticated = YES;
									self.touchIDStatusImageView.image = [self imageForAuthSuccess:YES];
									[self checReadyForVoiceCommand];
								}
								else {
									NSLog(@"bad!");
									self.touchIDAuthenticated = NO;
									self.touchIDStatusImageView.image = [self imageForAuthSuccess:NO];
								}
								self.touchIDStatusImageView.hidden = NO;
							});
						}];
}

- (IBAction)sign:(id)sender
{
	NSLog(@"sign:");
	
	self.fidoStatusProgressView.hidden = NO;
	self.fidoStatusImageView.image = nil;
	
	SecurityHelper *sh = [SecurityHelper sharedHelper];
	sh.serverAddress = SECURITY_FIDO_ADDRESS;
	sh.serverUsername = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice][PLTDefaultsKeySecurityFIDOUsername];
	sh.serverPassword = SECURITY_FIDO_PASSWORD;
	[sh sign:self];
}

- (void)didGetUnlockVoiceCommand
{
	NSLog(@"didGetUnlockVoiceCommand");
	
	if (self.touchIDAuthenticated && self.fidoAuthenticated) {
		NSDictionary *device = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice];
		NSLog(@"Unlocking %@...", device[PLTDefaultsKeySecurityDeviceName]);
		NSString *lockID = device[PLTDefaultsKeySecurityDeviceID];
		[self setLockState:PLTLockStateUnlocked lockID:lockID];
		[self startLockTimer];
		
		self.unlocked = YES;
//		self.touchIDAuthenticated = NO;
//		self.fidoAuthenticated = NO;
//		self.touchIDButton.enabled = YES;
//		self.fidoButton.enabled = YES;
//		self.touchIDStatusImageView.image = nil;
//		self.fidoStatusImageView.image = nil;
//		self.fidoStatusProgressView.hidden = YES;
//		self.fidoStatusLabel.text = @"";
//		self.authStatusLabel.hidden = YES;
	}
	else {
		NSLog(@"Not authenticated.");
	}
}

- (void)didGetLockVoiceCommand
{
	NSLog(@"didGetLockVoiceCommand");
	
	if (self.unlocked) {
		[self resetState];
	}
}

- (UIImage *)imageForAuthSuccess:(BOOL)flag
{
	if (flag) return [UIImage imageNamed:@"greencheck.png"];
	return [UIImage imageNamed:@"redx.png"];
}

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	NSLog(@"deviceDidOpenConnectionNotification");
	
	[self resetState];
	[self subscribeToServices];
}

- (void)deviceDidCloseConnectionNotification:(NSNotification *)note
{
	NSLog(@"deviceDidCloseConnectionNotification:");
	
	[self resetState];
}

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	if (CONNECTED_DEVICE) {
//		NSError *err = nil;
//		[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModePeriodic andPeriod:250 error:&err];
//		if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
		
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:0x0016 // voice commands
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOnChange
																							period:0];
		[SENSOR_DEVICE sendMessage:message];
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (void)unsubscribeFromServices
{
	NSLog(@"unsubscribeFromServices");
	
	if (CONNECTED_DEVICE) {
		//[d unsubscribeFromAll:self];
		
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:0x0016 // voice commands
																					characteristic:0
																							  mode:BRDefinedValue_SubscribeToServicesCommand_Mode_ModeOff
																							period:0];
		[SENSOR_DEVICE sendMessage:message];
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (BOOL)checkReachability
{
	NetworkStatus status = [self.reachability currentReachabilityStatus];
	
	if (status==ReachableViaWiFi || status==ReachableViaWWAN) {
		self.reachabilityImageView.alpha = 0.0;
		return YES;
	}
	else {
		self.reachabilityImageView.alpha = 1.0;
	}
	return NO;
}

- (void)deviceChanged:(NSNotification *)aNotification
{
	NSLog(@"deviceChanged:");
	NSLog(@"device: %@", [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice]);
}

- (void)checReadyForVoiceCommand
{
	if (self.touchIDAuthenticated && self.fidoAuthenticated) {
		self.authStatusLabel.hidden = NO;
		CONNECTED_DEVICE.passthroughDelegate = self; // listen for voice events
	}
}

- (void)setLockState:(PLTLockState)state lockID:(NSString *)lockID
{
	NSString *accessToken = @"0ed01e72a1374dd306f92e4b042653e37c13bb2f65517963fcc42f6c27636881";
	NSString *urlString = [NSString stringWithFormat:@"https://api.lockitron.com/v2/locks/%@", lockID];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"PUT"];
	NSString *lockUnlock = (state == PLTLockStateLocked ? @"lock" : @"unlock");
	NSString *argString = [NSString stringWithFormat:@"access_token=%@&state=%@", accessToken, lockUnlock];
	NSData *argData = [argString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:argData];
	[request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[argData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	self.lockConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)startLockTimer
{
	NSLog(@"startLockTimer");
	[self stopLockTimer];
	self.lockTimer = [NSTimer scheduledTimerWithTimeInterval:RELOCK_DELAY target:self selector:@selector(lockTimer:) userInfo:nil repeats:NO];
}

- (void)stopLockTimer
{
	NSLog(@"stopLockTimer");
	if (self.lockTimer) {
		[self.lockTimer invalidate];
		self.lockTimer = nil;
	}
}

- (void)lockTimer:(NSTimer *)aTimer
{
	NSLog(@"lockTimer:");
	[self resetState];
}

- (void)resetState
{
	NSDictionary *device = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice];
	NSLog(@"Locking %@...", device[PLTDefaultsKeySecurityDeviceName]);
	NSString *lockID = device[PLTDefaultsKeySecurityDeviceID];
	[self stopLockTimer];
	[self setLockState:PLTLockStateLocked lockID:lockID];
	
	self.touchIDAuthenticated = NO;
	self.fidoAuthenticated = NO;
	self.touchIDButton.enabled = (CONNECTED_DEVICE != nil);
	self.fidoButton.enabled = (CONNECTED_DEVICE != nil);
	self.touchIDStatusImageView.image = nil;
	self.fidoStatusImageView.image = nil;
	self.fidoStatusProgressView.hidden = YES;
	self.fidoStatusLabel.text = @"";
	self.authStatusLabel.hidden = YES;
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - PLTDeviceBRDevicePassthroughDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
	//NSLog(@"BRDeviceDidConnect: %@", device);
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
	//NSLog(@"BRDeviceDidDisconnect: %@", device);
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
	//NSLog(@"BRDevice: %@ didFailConnectWithError: %d", device, ioBTError);
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
	NSLog(@"BRDevice: %@ didReceiveEvent: %@", device, event);
	
	if ([event isKindOfClass:[BRSubscribedServiceDataEvent class]]) {
		BRSubscribedServiceDataEvent *sde = (BRSubscribedServiceDataEvent *)event;
		if (sde.serviceID == 0x0016) { // voice command
			uint8_t command;
			[sde.serviceData getBytes:&command length:sizeof(uint8_t)];
			NSLog(@"Voice command with ID: %02X", command);
			if (command == 0x0B) { // "unlock"
				[self didGetUnlockVoiceCommand];
			}
			else if (command==0x08) { // "secure"
				[self didGetLockVoiceCommand];
			}
		}
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResult:(BRSettingResult *)result
{
	//NSLog(@"BRDevice: %@ didReceiveSettingResult: %@", device, result);
}

- (void)BRDevice:(BRDevice *)device didRaiseSettingException:(BRException *)exception
{
	//NSLog(@"BRDevice: %@ didRaiseSettingException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didRaiseCommandException:(BRException *)exception
{
	//NSLog(@"BRDevice: %@ didRaiseCommandException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice
{
	//NSLog(@"BRDevice: %@ didFindRemoteDevice: %@", device, remoteDevice);
}

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
	//NSString *hexString = PLTHexStringFromData(data, 2);
	//NSLog(@"--> %@", hexString);
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	//NSString *hexString = PLTHexStringFromData(data, 2);
	//NSLog(@"<-- %@", hexString);
}

#pragma mark - SecurityHelperSignDelegate

- (void)securityHelper:(SecurityHelper *)theHelper didUpdateSigningState:(SigningState)state
{
	NSLog(@"securityHelper: %@ didUpdateSigningState: %d", theHelper, state);
	
	self.fidoStatusProgressView.hidden = NO;
	switch (state) {
		case SigningStateRetrievingEnrollments:
			//self.fidoStatusLabel.text = @"Getting enrollment data from server...";
			self.fidoStatusLabel.text = @"Retrieving challenge request from server...";
			break;
		case SigningStateSigningOnDevice:
			//self.fidoStatusLabel.text = @"Signing enrollment on headset...";
			self.fidoStatusLabel.text = @"Signing challenge on Plantronics device...";
			break;
		case SigningStateVerifyingSignatureWithServer:
			//self.fidoStatusLabel.text = @"Verifying signature on server...";
			self.fidoStatusLabel.text = @"Sending signature to server...";
			break;
	}
}

- (void)securityHelperDidAuthenticate:(SecurityHelper *)theHelper
{
	NSLog(@"securityHelperDidAuthenticate: %@", theHelper);
	
	self.fidoAuthenticated = YES;
	self.fidoStatusImageView.image = [self imageForAuthSuccess:YES];
	self.fidoStatusImageView.hidden = NO;
	self.fidoStatusProgressView.hidden = YES;
	self.fidoStatusLabel.text = @"";
	[self checReadyForVoiceCommand];
}

- (void)securityHelperDidFailAuthenticate:(SecurityHelper *)theHelper
{
	NSLog(@"securityHelperDidFailAuthenticate: %@", theHelper);
	
	self.fidoAuthenticated = NO;
	self.fidoStatusImageView.image = [self imageForAuthSuccess:NO];
	self.fidoStatusImageView.hidden = NO;
	self.fidoStatusProgressView.hidden = YES;
	self.fidoStatusLabel.text = @"";
	[self checReadyForVoiceCommand];
}

- (void)securityHelper:(SecurityHelper *)theHelper didEncounterErrorAuthenticating:(NSError *)error
{
	NSLog(@"securityHelper: %@ didEncounterErrorAuthenticating: %@", theHelper, error);
	
	[CONNECTED_DEVICE closeConnection];
	[self resetState];
	
	self.fidoAuthenticated = NO;
	self.fidoStatusImageView.image = [self imageForAuthSuccess:NO];
	self.fidoStatusImageView.hidden = NO;
	self.fidoStatusProgressView.hidden = YES;
	self.fidoStatusLabel.text = @"";
	[self checReadyForVoiceCommand];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection:didReceiveResponse: %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection:didReceiveData: %@", data);
	
	NSError *error;
	id parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error) {
		NSLog(@"Error deserializing JSON data: %@", error);
	}
	else {
		NSLog(@"parsedData: %@", parsedData);
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
{
	NSLog(@"connection:didSendBodyData: %lu", (long)bytesWritten);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading: %@", connection);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	//self = [super initWithNibName:@"SecurityViewController_3D" bundle:nibBundleOrNil];
	
	self.title = @"Security";
	self.tabBarItem.title = @"Security";
	self.tabBarItem.image = [UIImage imageNamed:@"security_tab_icon.png"];
	
	self.reachability = [Reachability reachabilityForInternetConnection];
	[[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		NSLog(@"kReachabilityChangedNotification");
		if ([self checkReachability]) {
			//[self connectOpenTok];
		}
	}];
	[self.reachability startNotifier];
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationController.navigationBarHidden = NO;
	
	self.view.backgroundColor = [UIColor grayColor];
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_banner.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeCenter;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_nav_icon.png"]
																	style:UIBarButtonItemStylePlain
																   target:[UIApplication sharedApplication].delegate
																   action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = settingItem;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.reachabilityImageView.alpha = 0.0;
	
	[self resetState];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.reachabilityImageView) {
		self.reachabilityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		self.reachabilityImageView.contentMode = UIViewContentModeCenter;
		self.reachabilityImageView.image = [UIImage imageNamed:(IPAD ? @"no_internet_ipad.png" : @"no_internet_iphone.png")];
		self.reachabilityImageView.alpha = 0.0;
		[self.view addSubview:self.reachabilityImageView];
	}
	
	if ([self checkReachability]) {
		
	}
	
	[self subscribeToServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidCloseConnectionNotification:) name:PLTDeviceDidCloseConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceChanged:) name:PLTSettingsSecurityDeviceChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self resetState];
	[self unsubscribeFromServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc removeObserver:self name:PLTDeviceDidCloseConnectionNotification object:nil];
	[nc removeObserver:self name:PLTSettingsSecurityDeviceChangedNotification object:nil];
}

@end
