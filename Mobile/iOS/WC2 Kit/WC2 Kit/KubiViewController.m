//
//  KubiViewController.m
//  PLTSensor
//
//  Created by Morgan Davis on 12/9/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import "KubiViewController.h"
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import <OpenTok/OpenTok.h>
#import "PLTDeviceHelper.h"
#import "Reachability.h"
#import "SettingsViewController.h"


NSString *NSStringFromPLTKubiPositioningMode(PLTKubiPositioningMode mode)
{
	switch (mode) {
		case PLTKubiPositioningModeJoystick: return @"Joystick";
		case PLTKubiPositioningModeAbsolute:return @"Absolute";
	}
	return nil;
}


@interface KubiViewController () <PLTDeviceSubscriber, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherKitDelegate>

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)subscribeToServices;
- (void)unsubscribeFromServices;
- (BOOL)checkReachability;
- (void)connectOpenTok;
- (void)disconnectOpenTok:(BOOL)delayed;
//- (void)zeroButton:(id)sender;
- (void)deviceChanged:(NSNotification *)aNotification;
- (void)settingsChanged:(NSNotification *)aNotification;
- (void)orientationCalibrated:(NSNotification *)aNotification;
- (void)sendStop;

@property(nonatomic,strong)	OTSession		*otSession;
@property(nonatomic,strong)	OTSubscriber	*otRemoteSubscriber;
@property(nonatomic,strong)	OTConnection	*otRemoteSubscriberConnection;
@property(nonatomic,strong)	OTPublisher		*otPublisher;
@property(nonatomic,strong)	OTPublisher		*otSubscriber;
@property(nonatomic,strong)	Reachability	*reachability;
@property(nonatomic,strong)	UIImageView		*reachabilityImageView;

@end


@implementation KubiViewController

#pragma mark - Private

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self subscribeToServices];
}

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	if (CONNECTED_DEVICE) {
		NSError *err = nil;
		[CONNECTED_DEVICE subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModePeriodic andPeriod:100 error:&err];
		//[CONNECTED_DEVICE subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (void)unsubscribeFromServices
{
	NSLog(@"unsubscribeFromServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (CONNECTED_DEVICE) {
		[d unsubscribeFromAll:self];
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

- (void)connectOpenTok
{
	NSLog(@"connectOpenTok");
	
	if (self.isViewLoaded && self.view.window) {
		[self disconnectOpenTok:NO];
		
		NSDictionary *deviceSettings = [DEFAULTS objectForKey:PLTDefaultsKeyKubiDevice];
		NSString *name = deviceSettings[PLTDefaultsKeyKubiDeviceName];
		NSString *APIKey = deviceSettings[PLTDefaultsKeyKubiDeviceTokBoxAPIKey];
		NSString *sessionID = deviceSettings[PLTDefaultsKeyKubiDeviceTokBoxSessionID];
		NSString *publisherID = deviceSettings[PLTDefaultsKeyKubiDeviceTokBoxPublisherIDiPad];
		
		NSLog(@"Connecting for session for device name \"%@\"...", name);
		
		self.otSession = [[OTSession alloc] initWithApiKey:APIKey sessionId:sessionID delegate:self];
		
		OTError *error = nil;
		[self.otSession connectWithToken:publisherID error:&error];
		if (error) {
			NSLog(@"Error connecting to session: %@", error);
		}
	}
	else {
		NSLog(@"Aborting. View isn't visible.");
	}
}

- (void)disconnectOpenTok:(BOOL)delayed
{
	NSLog(@"disconnectOpenTok: %@", (delayed ? @"YES" : @"NO"));
	
	[self sendStop];
	
	if (delayed) {
		int64_t delayInSeconds = .5;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self.otPublisher.view removeFromSuperview];
			[self.otRemoteSubscriber.view removeFromSuperview];
			[self.otSession disconnect:nil];
		});
	}
	else {
		[self.otPublisher.view removeFromSuperview];
		[self.otRemoteSubscriber.view removeFromSuperview];
		[self.otSession disconnect:nil];
	}
}

//- (void)zeroButton:(id)sender
//{
//	NSLog(@"zeroButton:");
//	
//	NSError *err = nil;
//	[CONNECTED_DEVICE setCalibration:nil forService:PLTServiceOrientation error:&err];
//	if (err) {
//		NSLog(@"Error calibrating orientation tracking: %@", err);
//	}
//}

- (void)deviceChanged:(NSNotification *)aNotification
{
	NSLog(@"deviceChanged:");
	[self connectOpenTok];
}

- (void)settingsChanged:(NSNotification *)aNotification
{
	NSLog(@"settingsChanged:");
	
	BOOL absolute = ([DEFAULTS integerForKey:PLTDefaultsKeyKubiMode] == PLTKubiPositioningModeAbsolute);
	BOOL mirror = [DEFAULTS boolForKey:PLTDefaultsKeyKubiMirror];
	
	NSString *signalString = [NSString stringWithFormat:@"%@,%@", (absolute ? @"y": @"n"), (mirror ? @"y": @"n")];
	OTError *error = nil;
	[self.otSession signalWithType:@"stg" string:signalString connection:self.otRemoteSubscriberConnection error:&error];
	if (error) {
		NSLog(@"Error signaling: %@", error);
	}
}


- (void)orientationCalibrated:(NSNotification *)aNotification
{
	NSLog(@"orientationCalibrated:");
	
	OTError *error = nil;
	[self.otSession signalWithType:@"zero" string:@"" connection:self.otRemoteSubscriberConnection error:&error];
	if (error) {
		NSLog(@"Error signaling: %@", error);
	}
}

- (void)sendStop
{
	NSLog(@"sendStop");
	
	OTError *error = nil;
	[self.otSession signalWithType:@"stop" string:@"" connection:self.otRemoteSubscriberConnection error:&error];
	if (error) {
		NSLog(@"Error signaling: %@", error);
	}
}

//- (void)startHT
//{
//	NSError *err = nil;
//	
//	//[self.device subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//	[self.device subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModePeriodic andPeriod:250 error:&err];
//	if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
//	
//	// "zero" orientation tracking to current orientation
//	
//	[self.device setCalibration:nil forService:PLTServiceOrientation error:&err];
//	if (err) NSLog(@"Error calibrating orientation tracking: %@", err);
//}

#pragma mark - OTSessionDelegate

/** @name Connecting to a session */

/**
 * Sent when the client connects to the session.
 *
 * @param session The <OTSession> instance that sent this message.
 */
- (void)sessionDidConnect:(OTSession*)session
{
	NSLog(@"sessionDidConnect:");
	
	// publish our stream
	
	self.otPublisher = [[OTPublisher alloc] initWithDelegate:self name:@"Scarlett"];
	self.otPublisher.publishAudio = false;
	OTError *error = nil;
	[self.otSession publish:self.otPublisher error:&error];
	if (error) {
		NSLog(@"Error publishing stream: %@", error);
	}
	[self.otPublisher.view setFrame:CGRectMake(64, 1024 - 48 - 240 - 12, 320, 240)];
	[self.view addSubview:self.otPublisher.view];
	if (self.otSubscriber.view) {
		[self.view insertSubview:self.otPublisher.view aboveSubview:self.otSubscriber.view];
	}
	else {
		[self.view addSubview:self.otPublisher.view];
	}
}

/**
 * Sent when the client disconnects from the session.
 *
 * When a session disconnects, all <OTSubscriber> and <OTPublisher> objects' views are
 * removed from their superviews.
 *
 * @param session The <OTSession> instance that sent this message.
 */
- (void)sessionDidDisconnect:(OTSession*)session
{
	NSLog(@"sessionDidDisconnect:");
	
	[self.otPublisher.view removeFromSuperview];
	[self.otRemoteSubscriber.view removeFromSuperview];
}

/**
 * Sent if the session fails to connect, some time after your applications sends the
 * [OTSession connectWithApiKey:token:] message.
 *
 * @param session The <OTSession> instance that sent this message.
 * @param error An <OTError> object describing the issue. The `OTSessionErrorCode` enum
 * (defined in the OTError class) defines values for the `code` property of this object.
 */
- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
	NSLog(@"session:didFailWithError: %@", error);
}

/**
 * Sent when a new stream is created in this session.
 *
 * Note that if your application publishes to this session, your own session
 * delegate will not receive the [OTSessionDelegate session:streamCreated:]
 * message for its own published stream. For that event, see the delegate 
 * callback [OTPublisherKit publisher:streamCreated:].
 *
 * @param session The OTSession instance that sent this message.
 * @param stream The stream associated with this event.
 */
- (void)session:(OTSession*)session streamCreated:(OTStream*)stream
{
	NSLog(@"session:streamCreated: %@", stream);
	
	[self.otRemoteSubscriber.view removeFromSuperview];
	self.otRemoteSubscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
	OTError* error = nil;
	[session subscribe:self.otRemoteSubscriber error:&error];
	if (error) {
		NSLog(@"Subscribe failed with error: %@", error);
	}
	else {
		// since we're now streaming audio and video to Kubi, start sending HT data
		
		// 14/12/10: Morgan: Since we moved this code from the standalone app "KubiPeerTest" we just enable HT whenever the "Kubi" tab is selected...
		//[self startHT];
		
		//[self settingsChanged:nil];
	}
}

/**
 * Sent when a stream is no longer published to the session.
 *
 * @param session The <OTSession> instance that sent this message.
 * @param stream The stream associated with this event.
 */
- (void)session:(OTSession*)session streamDestroyed:(OTStream*)stream
{
	NSLog(@"session:streamDestroyed: %@", stream);
}

//@optional

/** @name Monitoring connections in a session */

/**
 * Sent when another client connects to the session. The `connection` object
 * represents the client's connection.
 *
 * This message is not sent when your own client connects to the session. 
 * Instead, the <[OTSessionDelegate sessionDidConnect:]>
 * message is sent when your own client connects to the session.
 *
 * @param session The <OTSession> instance that sent this message.
 * @param connection The new <OTConnection> object.
 */
- (void)session:(OTSession*)session connectionCreated:(OTConnection*)connection
{
	NSLog(@"session:connectionCreated: %@", connection);
	
	self.otRemoteSubscriberConnection = connection;
}

/**
 * Sent when another client disconnects from the session. The `connection`
 * object represents the connection that the client had to the session.
 *
 * This message is not sent when your own client disconnects from the session. 
 * Instead, the <[OTSessionDelegate sessionDidDisconnect:]>
 * message is sent when your own client connects to the session.
 *
 * @param session The <OTSession> instance that sent this message.
 * @param connection The <OTConnection> object for the client that disconnected
 * from the session.
 */
- (void)session:(OTSession*)session connectionDestroyed:(OTConnection*)connection
{
	NSLog(@"session:connectionDestroyed: %@", connection);
}

/**
 * Sent when a message is received in the session.
 * @param session The <OTSession> instance that sent this message.
 * @param type The type string of the signal.
 * @param connection The connection identifying the client that sent the
 * message.
 * @param string The signal data.
 */
- (void)session:(OTSession*)session receivedSignalType:(NSString*)type fromConnection:(OTConnection*)connection withString:(NSString*)string
{
	NSLog(@"session:receivedSignalType: %@ fromConnection: %@ withString: %@", type, connection, string);
}

/** @name Monitoring archiving events */

/**
 * Sent when an archive recording of a session starts. If you connect to a
 * session in which recording is already in progress, this message is sent
 * when you connect.
 *
 * In response to this message, you may want to add a user interface
 * notification (such as an icon in the Publisher view) that indicates
 * that the session is being recorded.
 *
 * For more information see the OpenTok
 * [Archiving Overview]( http://www.tokbox.com/opentok/tutorials/archiving ).
 *
 * @param session The <OTSession> instance that sent this message.
 * @param archiveId The unique ID of the archive.
 * @param name The name of the archive (if one was provided when the archive
 * was created).
 */
- (void)session:(OTSession*)session archiveStartedWithId:(NSString*)archiveId name:(NSString*)name
{
	NSLog(@"session:archiveStartedWithId: %@ name: %@", archiveId, name);
}

/**
 * Sent when an archive recording of a session stops.
 *
 * In response to this message, you may want to change or remove a user
 * interface notification (such as an icon in the Publisher view) that
 * indicates that the session is being recorded.
 *
 * For more information, see the OpenTok
 * [Archiving Overview]( http://www.tokbox.com/opentok/tutorials/archiving ).
 *
 * @param session The <OTSession> instance that sent this message.
 * @param archiveId The unique ID of the archive.
 */
- (void)session:(OTSession*)session archiveStoppedWithId:(NSString*)archiveId
{
	NSLog(@"session:archiveStoppedWithId: %@ ", archiveId);
}

#pragma mark - OTSubscriberKitDelegate

/** @name Using subscribers */

/**
 * Sent when the subscriber successfully connects to the stream.
 * @param subscriber The subscriber that generated this event.
 */
- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
	NSLog(@"subscriberDidConnectToStream:");
	
	// display Kubi's stream
	
	self.otSubscriber = subscriber;
	
	//[self.otRemoteSubscriber.view setFrame:CGRectMake(0, 232, 768, 576)]; // centered
	[self.otRemoteSubscriber.view setFrame:CGRectMake(0, 232 - 32 - 16, 768, 576)]; // offset
	//[self.view addSubview:self.otRemoteSubscriber.view];
	[self.view insertSubview:self.otRemoteSubscriber.view atIndex:0];
	
	[self settingsChanged:nil];
}

/**
 * Sent if the subscriber fails to connect to its stream.
 * @param subscriber The subscriber that generated this event.
 * @param error The error (an <OTError> object) that describes this connection
 * error. The `OTSubscriberErrorCode` enum (defined in the OTError class)
 * defines values for the `code` property of this object.
 */
- (void)subscriber:(OTSubscriberKit*)subscriber didFailWithError:(OTError*)error
{
	NSLog(@"subscriber:didFailWithError: %@", error);
}

//@optional

/**
 * This message is sent when the subscriber stops receiving video.
 * Check the reason parameter for the reason why the video stopped.
 *
 * @param subscriber The <OTSubscriber> that will no longer receive video.
 * @param reason The reason that the video track was disabled. See
 * <OTSubscriberVideoEventReason>.
 */
- (void)subscriberVideoDisabled:(OTSubscriberKit*)subscriber reason:(OTSubscriberVideoEventReason)reason
{
	NSLog(@"subscriberVideoDisabled:reason: %d", reason);
}

/**
 * This message is sent when the subscriber starts (or resumes) receiving video.
 * Check the reason parameter for the reason why the video started (or resumed).
 *
 * @param subscriber The <OTSubscriber> that will no longer receive video.
 * @param reason The reason that the video track was enabled. See
 * <OTSubscriberVideoEventReason>.
 */
- (void)subscriberVideoEnabled:(OTSubscriberKit*)subscriber reason:(OTSubscriberVideoEventReason)reason
{
	NSLog(@"subscriberVideoEnabled:reason: %d", reason);
}

/**
 * This message is sent when the OpenTok Media Router determines that the stream
 * quality has degraded and the video will be disabled if the quality degrades
 * further. If the quality degrades further, the subscriber disables the video
 * and the <[OTSubscriberKitDelegate subscriberVideoDisabled:reason:]> message
 * is sent. If the stream quality improves, the
 * <[OTSubscriberKitDelegate subscriberVideoDisableWarningLifted:]> message is
 * sent.
 *
 * This feature is only available in sessions that use the
 * OpenTok Media Router (sessions with the
 * [media mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
 * set to routed), not in sessions with the media mode set to relayed.
 *
 * This message is mainly sent when connection quality degrades.
 *
 * @param subscriber The <OTSubscriber> that may stop receiving video soon.
 */
- (void)subscriberVideoDisableWarning:(OTSubscriberKit*)subscriber
{
	NSLog(@"subscriberVideoDisableWarning: %@", subscriber);
}

/**
 * This message is sent when the OpenTok Media Router determines that the stream
 * quality has improved to the point at which the video being disabled is not an
 * immediate risk. This message is sent after the
 * <[OTSubscriberKitDelegate subscriberVideoDisableWarning:]> message is
 * sent.
 *
 * This feature is only available in sessions that use the
 * OpenTok Media Router (sessions with the
 * [media mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
 * set to routed), not in sessions with the media mode set to relayed.
 *
 * This message is mainly sent when connection quality improves.
 *
 * @param subscriber The <OTSubscriber> instance.
 */
- (void)subscriberVideoDisableWarningLifted:(OTSubscriberKit*)subscriber
{
	NSLog(@"subscriberVideoDisableWarningLifted: %@", subscriber);
}

#pragma mark - OTPublisherKitDelegate

/**
 * Sent if the publisher encounters an error. After this message is sent,
 * the publisher can be considered fully detached from a session and may
 * be released.
 * @param publisher The publisher that signalled this event.
 * @param error The error (an <OTError> object). The `OTPublisherErrorCode` 
 * enum (defined in the OTError class)
 * defines values for the `code` property of this object.
 */
- (void)publisher:(OTPublisherKit*)publisher didFailWithError:(OTError*)error
{
	NSLog(@"publisher:didFailWithError: %@", error);
}

//@optional

/**
 * Sent when the publisher starts streaming.
 *
 * @param publisher The publisher of the stream.
 * @param stream The stream that was created.
 */
- (void)publisher:(OTPublisherKit*)publisher streamCreated:(OTStream*)stream
{
	NSLog(@"publisher:streamCreated: %@", stream);
}

/**
 * Sent when the publisher stops streaming.
 * @param publisher The publisher that stopped sending this stream.
 * @param stream The stream that ended.
 */
- (void)publisher:(OTPublisherKit*)publisher streamDestroyed:(OTStream*)stream
{
	NSLog(@"publisher:streamDestroyed: %@", stream);
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	// since we subscribed to receive info updates (and conform to the PLTDeviceInfoObserver protocol), this method is called when new device info is available.
	// we must check the info's 'class' to see which subclass of PLTInfo it is.
	
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		if (self.otRemoteSubscriberConnection) { // if nobody's listening, don't send it
			PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
			NSString *signalString = [NSString stringWithFormat:@"%.1f,%.1f", eulerAngles.x, eulerAngles.y];
			NSLog(@"sending: %@", signalString);
			OTError *error = nil;
			[self.otSession signalWithType:@"ht" string:signalString connection:self.otRemoteSubscriberConnection error:&error];
			if (error) {
				NSLog(@"Error signaling: %@", error);
			}
		}
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	self.title = @"Kubi";
	self.tabBarItem.title = @"Kubi";
	self.tabBarItem.image = [UIImage imageNamed:@"kubi_tab_icon.png"];
	
	self.reachability = [Reachability reachabilityForInternetConnection];
	[[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		NSLog(@"kReachabilityChangedNotification");
		if ([self checkReachability]) {
			[self connectOpenTok];
		}
	}];
	[self.reachability startNotifier];
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationController.navigationBarHidden = NO;
	
	self.view.backgroundColor = [UIColor colorWithRed:64.0/256.0 green:66.0/256.0 blue:74.0/256.0 alpha:1.0];
	
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
	
//	UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zero_nav_icon.png"]
//																	 style:UIBarButtonItemStylePlain
//																	target:self
//																	action:@selector(zeroButton:)];
//	self.navigationItem.leftBarButtonItem = locationItem;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.reachabilityImageView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.reachabilityImageView) {
		self.reachabilityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		self.reachabilityImageView.contentMode = UIViewContentModeCenter;
		self.reachabilityImageView.image = [UIImage imageNamed:@"no_internet_connection.png"];
		self.reachabilityImageView.alpha = 0.0;
		[self.view addSubview:self.reachabilityImageView];
	}
	
	if ([self checkReachability]) {
		[self connectOpenTok];
	}
	
	[self subscribeToServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceChanged:) name:PLTSettingsKubiDeviceChangedNotification object:nil];
	[nc addObserver:self selector:@selector(settingsChanged:) name:PLTSettingsKubiSettingsChangedNotification object:nil];
	[nc addObserver:self selector:@selector(orientationCalibrated:) name:PLTDeviceHandlerDidCalibrateOrientationNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self unsubscribeFromServices];
	[self disconnectOpenTok:YES];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc removeObserver:self name:PLTSettingsKubiDeviceChangedNotification object:nil];
	[nc removeObserver:self name:PLTSettingsKubiSettingsChangedNotification object:nil];
	[nc removeObserver:self name:PLTDeviceHandlerDidCalibrateOrientationNotification object:nil];
}

@end
