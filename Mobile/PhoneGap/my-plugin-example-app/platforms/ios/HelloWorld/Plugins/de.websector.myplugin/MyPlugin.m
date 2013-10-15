#import "MyPlugin.h"
#import "PLTDevice.h"


@interface MyPlugin() <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

- (void)startFreeFallResetTimer;
- (void)stopFreeFallResetTimer;
- (void)freeFallResetTimer:(NSTimer *)theTimer;
- (void)startTapsResetTimer;
- (void)stopTapsResetTimer;
- (void)tapsResetTimer:(NSTimer *)theTimer;

@property(nonatomic,strong)		PLTDevice					*device;
@property(nonatomic,strong)		PLTOrientationTrackingInfo	*lastOrientationInfo;
@property(nonatomic,strong)		NSMutableDictionary			*latestInfo;
@property(nonatomic, strong)	NSTimer						*freeFallResetTimer;
@property(nonatomic, strong)	NSTimer						*tapsResetTimer;

@end


@implementation MyPlugin

#pragma mark - PhoneGap Plugin Public

- (void)connect:(CDVInvokedUrlCommand*)command
{
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[devices description]];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getIsConnected:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:(self.device.isConnectionOpen ? @"YES" : @"NO")];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)calibrate:(CDVInvokedUrlCommand*)command
{
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
	
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Shwing"];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getEulerAngles:(CDVInvokedUrlCommand*)command
{
	NSString *eulerString = NSStringFromEulerAngles(self.lastOrientationInfo.eulerAngles);
	
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:eulerString];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getLatestInfo:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.latestInfo];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Private

- (void)startFreeFallResetTimer
{
	// currrently free fall is only reported as info indicating isInFreeFall, immediately followed by info indicating !isInFreeFall (during is not yet supported)
	// so to make sure the user sees a visual indication of the device having been in/is in free fall, a timer is used to display "Free Fall? yes" for three seconds.
	
	[self stopFreeFallResetTimer];
	self.freeFallResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(freeFallResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopFreeFallResetTimer
{
	if ([self.freeFallResetTimer isValid]) {
		[self.freeFallResetTimer invalidate];
		self.freeFallResetTimer = nil;
	}
}

- (void)freeFallResetTimer:(NSTimer *)theTimer
{
	self.latestInfo[@"freeFall"] = @"no";
}

- (void)startTapsResetTimer
{
	// since taps are only reported in one brief info update, a timer is used to display the most recent taps for three seconds.
	
	[self stopTapsResetTimer];
	self.tapsResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(tapsResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopTapsResetTimer
{
	if ([self.tapsResetTimer isValid]) {
		[self.tapsResetTimer invalidate];
		self.tapsResetTimer = nil;
	}
}

- (void)tapsResetTimer:(NSTimer *)theTimer
{
	self.latestInfo[@"taps"] = @"-";
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
	
	self.latestInfo = [NSMutableDictionary dictionary];
	
//	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
//	if (err) NSLog(@"Error: %@", err);
	
	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	// note: this doesn't work right.
	err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceMagnetometerCalStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
}

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTOrientationTrackingInfo *orientationInfo = (PLTOrientationTrackingInfo *)theInfo;
		NSLog(@"Orientation info: %@", NSStringFromEulerAngles(orientationInfo.eulerAngles));
		self.lastOrientationInfo = orientationInfo;
	}
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
		self.latestInfo[@"angles"] = NSStringFromEulerAngles(eulerAngles);
	}
	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
		self.latestInfo[@"wearState"] = (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no");
	}
	else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
		PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
		self.latestInfo[@"pcProximity"] = NSStringFromProximity(proximityInfp.pcProximity);
		self.latestInfo[@"mobileProximity"] = NSStringFromProximity(proximityInfp.mobileProximity);
	}
	else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
		self.latestInfo[@"pedCount"] = [NSString stringWithFormat:@"%u", ((PLTPedometerInfo *)theInfo).steps];
	}
	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
		BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
		self.latestInfo[@"freeFall"] = (isInFreeFall ? @"yes" : @"no");
		if (isInFreeFall) {
			[self startFreeFallResetTimer];
		}
	}
	else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
		PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
		NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
		self.latestInfo[@"taps"] = [NSString stringWithFormat:@"%u in %@", tapsInfo.taps, directionString];
		[self startTapsResetTimer];
	}
	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
		self.latestInfo[@"magCal"] = (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"YES" : @"NO");
	}
	else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
		self.latestInfo[@"gyroCal"] = (((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"YES" : @"NO" );
	}
}

@end

