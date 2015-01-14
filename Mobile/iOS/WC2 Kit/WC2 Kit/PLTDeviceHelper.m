//
//  PLTDeviceHelper.h
//

#import "PLTDeviceHelper.h"
#import "PLTDevice.h"


#define DON_CALIBRATE_DELAY			2.0 // seconds


NSString *const PLTDeviceHandlerDidCalibrateOrientationNotification = @"PLTDeviceHandlerDidCalibrateOrientationNotification";


@interface PLTDLogger : NSObject
+ (PLTDLogger *)sharedLogger;
@property(nonatomic,assign)	NSInteger	level;
@end


@interface PLTDeviceHelper () <UIAccelerometerDelegate, PLTDeviceSubscriber>

- (void)log:(NSString *)format args:(NSString *)args, ...;
- (void)applicationDidBecomeActive:(NSNotification *)note;
- (BOOL)accelerationIsShaking:(UIAcceleration *)last current:(UIAcceleration *) current threshold:(double)threshold;
- (void)updateCalibration;

@property(nonatomic,strong)	PLTDevice		*device;
@property(nonatomic,assign) BOOL            deviceDonned;
@property(nonatomic,assign) BOOL            histeresisExcited;
@property(nonatomic,retain) UIAcceleration  *lastAcceleration;
@property(nonatomic,assign) double          theta_ave;
@property(nonatomic,assign) double          psi_ave;
@property(nonatomic,assign) long long       oldtime;

@end


@implementation PLTDeviceHelper

#pragma mark - Public

+ (PLTDeviceHelper *)sharedHelper
{
    static PLTDeviceHelper *handler = nil;
    if (!handler) {
        handler = [[PLTDeviceHelper alloc] init];
		
		//[PLTDLogger sharedLogger].level = 0;
		
		NSArray *devices = [PLTDevice availableDevices];
		if ([devices count]) {
			handler.device = devices[0];
			NSLog(@"Opening connection to %@...", handler.device);
			NSError *err = nil;
			[handler.device openConnection:&err];
			if (err) {
		  NSLog(@"Error opening connection: %@", err);
			}
		}
		else {
			NSLog(@"No available devices.");
		}
    }
    return handler;
}

- (PLTDevice *)connectedDevice
{
	NSArray *devices = [PLTDevice availableDevices];
	for (PLTDevice *d in devices) {
		if (d.isConnectionOpen) {
			return d;
		}
	}
	return nil;
}

#pragma mark - Private

- (void)applicationDidBecomeActive:(NSNotification *)note
{
    NSLog(@"applicationDidBecomeActive:");
	
	// check connection?
}

- (BOOL)accelerationIsShaking:(UIAcceleration *)last current:(UIAcceleration *) current threshold:(double)threshold
{
	double deltaX = fabs(last.x - current.x), deltaY = fabs(last.y - current.y), deltaZ = fabs(last.z - current.z);
	return (deltaX > threshold && deltaY > threshold) || (deltaX > threshold && deltaZ > threshold) || (deltaY > threshold && deltaZ > threshold);
}

- (void)updateCalibration
{
    NSLog(@"updateCalibration");
	
	NSError *err = nil;
	[self.device setCalibration:nil forService:PLTServiceOrientation error:&err];
	if (err) {
		NSLog(@"Error calibrating orientation tracking: %@", err);
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTDeviceHandlerDidCalibrateOrientationNotification object:nil];
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)device didUpdateInfo:(PLTInfo *)info
{
	if ([info isKindOfClass:[PLTWearingStateInfo class]]) {
		PLTWearingStateInfo *wearingInfo = (PLTWearingStateInfo *)info;
		BOOL donned = wearingInfo.isBeingWorn;
		if (!self.deviceDonned && donned) {
			// check cal
			if (self.headTrackingCalibrationTriggers & PLTHeadTrackingCalibrationTriggerDon) {
				[self updateCalibration];
			}
		}
		self.deviceDonned = donned;
	}
}
		
- (void)PLTDevice:(PLTDevice *)device didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	
}

#pragma mark - UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
	if (self.lastAcceleration) {
		if (!self.histeresisExcited && [self accelerationIsShaking:self.lastAcceleration current:acceleration threshold:0.7]) {
			self.histeresisExcited = YES;
            
			if (self.headTrackingCalibrationTriggers & PLTHeadTrackingCalibrationTriggerShake) {
				[self updateCalibration];
			}
            
		} else if (self.histeresisExcited && ![self accelerationIsShaking:self.lastAcceleration current:acceleration threshold:0.2]) {
			self.histeresisExcited = NO;
		}
	}
    
	self.lastAcceleration = acceleration;
}

#pragma mark - NSObject

- (id)init
{
    if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
		[UIAccelerometer sharedAccelerometer].delegate = self;
		
		// connection open
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
			
			NSLog(@"Device connection open: %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
			
			NSError *err = nil;
			
			// subscribe to wearing state for cal-on-don
			
			[self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to wearing state: %@", err);

			// "zero" orientation tracking to current orientation
			
			[self.device setCalibration:nil forService:PLTServiceOrientation error:&err];
			if (err) NSLog(@"Error calibrating orientation tracking: %@", err);
		}];
		
		// connection failed
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidFailOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
			PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			NSInteger error = [(NSNumber *)([note userInfo][PLTDeviceConnectionErrorNotificationKey]) intValue];
			
			NSLog(@"Device connection failed with error: %ld, device: %@", (long)error, device);
			
			self.device = nil;
		}];
		
		// connection closed
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidCloseConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
			PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			
			NSLog(@"Device connection closed: %@", device);
			
			self.device = nil;
		}];
		
		// new device available
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceAvailableNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
			PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			
			NSLog(@"Device available: %@", device);
			
			// if we're not already connected to a device, connect to this one.
			
			if (!self.device) {
				NSLog(@"Opening connection to %@...", device);
				self.device = device;
				NSError *err = nil;
				[self.device openConnection:&err];
				if (err) {
					NSLog(@"Error opening connection: %@", err);
				}
			}
		}];
	}
	return self;
}

@end
