//
//  MainWindowController.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MainWindowController.h"
#import "PLTDevice.h"


@interface MainWindowController () <PLTDeviceSubscriber>

- (IBAction)openConnectionButton:(id)sender;
- (IBAction)closeConnectionButton:(id)sender;
- (IBAction)subscribeToServicesButton:(id)sender;
- (IBAction)unsubscribeFromServicesButton:(id)sender;
- (IBAction)queryServicesButton:(id)sender;
- (IBAction)getCachedInfoButton:(id)sender;
- (IBAction)calibrateButton:(id)sender;
//- (IBAction)Button:(id)sender;
- (void)setUIConnected:(BOOL)flag;

@property(nonatomic,strong)		PLTDevice	*device;
@property(nonatomic,strong)		NSButton	*openConnectionButton;
@property(nonatomic,strong)		NSButton	*closeConnectionButton;
@property(nonatomic,strong)		NSButton	*subscribeToServicesButton;
@property(nonatomic,strong)		NSButton	*unsubscribeFromServicesButton;
@property(nonatomic,strong)		NSButton	*queryServicesButton;
@property(nonatomic,strong)		NSButton	*getCachedInfoButton;

@end


@implementation MainWindowController

#pragma mark - Private

- (IBAction)openConnectionButton:(id)sender
{
	NSLog(@"openConnectionButton:");
	
	if (!self.device) {
		NSArray *devices = [PLTDevice availableDevices];
        NSLog(@"availableDevices: %@", devices);
		if ([devices count]) {
			self.device = devices[0];
			[self.device openConnection];
		}
		else {
			NSLog(@"No devices!");
		}
	}
}

- (IBAction)closeConnectionButton:(id)sender
{
	NSLog(@"closeConnectionButton:");
	[self.device closeConnection];
}

- (IBAction)subscribeToServicesButton:(id)sender
{
	NSLog(@"subscribeToServicesButton:");
	
	if (self.device.isConnectionOpen) {
//		[self.device subscribe:self toService:PLTServiceOrientationTracking			withMode:PLTSubscriptionModeOnChange	andPeriod:0];
//		[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
		
		[self.device subscribe:self toService:PLTServicePedometer					withMode:PLTSubscriptionModeOnChange	andPeriod:0];
		[self.device subscribe:self toService:PLTServiceFreeFall					withMode:PLTSubscriptionModeOnChange	andPeriod:0];
		[self.device subscribe:self toService:PLTServiceTaps						withMode:PLTSubscriptionModeOnChange	andPeriod:0];
		[self.device subscribe:self toService:PLTServiceMagnetometerCalStatus		withMode:PLTSubscriptionModeOnChange	andPeriod:0];
		[self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus	withMode:PLTSubscriptionModeOnChange	andPeriod:0];
		[self.device subscribe:self toService:PLTServiceWearingState				withMode:PLTSubscriptionModeOnChange	andPeriod:0];
//		[self.device subscribe:self toService:PLTServiceProximity					withMode:PLTSubscriptionModeOnChange	andPeriod:0];
	}
}

- (IBAction)unsubscribeFromServicesButton:(id)sender
{
	NSLog(@"unsubscribeFromServicesButton:");
	
	[self.device unsubscribeFromAll:self];
}

- (IBAction)queryServicesButton:(id)sender
{
	NSLog(@"queryServicesButton:");
	
	if (self.device.isConnectionOpen) {
//		[self.device queryInfo:self forService:PLTServiceOrientationTracking];
//		[self.device queryInfo:self forService:PLTServicePedometer];
//		[self.device queryInfo:self forService:PLTServiceFreeFall];
//		[self.device queryInfo:self forService:PLTServiceTaps];
//		[self.device queryInfo:self forService:PLTServiceMagnetometerCalStatus];
//		[self.device queryInfo:self forService:PLTServiceGyroscopeCalibrationStatus];
//		[self.device queryInfo:self forService:PLTServiceWearingState];
		[self.device queryInfo:self forService:PLTServiceProximity];
	}
}

- (IBAction)getCachedInfoButton:(id)sender
{
	NSLog(@"getCachedInfoButton:");
	
	NSLog(@"PLTServiceOrientationTracking: %@", [self.device cachedInfoForService:PLTServiceOrientationTracking]);
	NSLog(@"PLTServicePedometer: %@", [self.device cachedInfoForService:PLTServicePedometer]);
	NSLog(@"PLTServiceFreeFall: %@", [self.device cachedInfoForService:PLTServiceFreeFall]);
	NSLog(@"PLTServiceTaps: %@", [self.device cachedInfoForService:PLTServiceTaps]);
	NSLog(@"PLTServiceMagnetometerCalStatus: %@", [self.device cachedInfoForService:PLTServiceMagnetometerCalStatus]);
	NSLog(@"PLTServiceGyroscopeCalibrationStatus: %@", [self.device cachedInfoForService:PLTServiceGyroscopeCalibrationStatus]);
	NSLog(@"PLTServiceWearingState: %@", [self.device cachedInfoForService:PLTServiceWearingState]);
	NSLog(@"PLTServiceProximity: %@", [self.device cachedInfoForService:PLTServiceProximity]);
}

- (IBAction)calibrateButton:(id)sender
{
	NSLog(@"calibrateButton:");
	
//	PLTOrientationTrackingInfo *oldOrientationInfo = (PLTOrientationTrackingInfo *)[self.device cachedInfoForService:PLTServiceOrientationTracking];
//	PLTOrientationTrackingCalibration *orientationCal = [PLTOrientationTrackingCalibration calibrationWithReferenceOrientationTrackingInfo:oldOrientationInfo];
//	//PLTOrientationTrackingCalibration *orientationCal = [PLTOrientationTrackingCalibration calibrationWithReferenceQuaternion:oldOrientationInfo.quaternion];
//	//PLTOrientationTrackingCalibration *orientationCal = [PLTOrientationTrackingCalibration calibrationWithReferenceEulerAngles:oldOrientationInfo.eulerAngles];
//	[self.device setCalibration:orientationCal forService:PLTServiceOrientationTracking];
	
//	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
	
	[self.device setCalibration:nil forService:PLTServicePedometer];
}

- (void)setUIConnected:(BOOL)flag
{
	[self.openConnectionButton setEnabled:!flag];
	[self.closeConnectionButton setEnabled:flag];
	[self.subscribeToServicesButton setEnabled:flag];
	[self.unsubscribeFromServicesButton setEnabled:flag];
	[self.queryServicesButton setEnabled:flag];
	[self.getCachedInfoButton setEnabled:flag];
}

#pragma mark - NSWindowController

- (id)init
{
	if (self = [super initWithWindowNibName:@"MainWindow.xib"]) {
        
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceAvailableNotification object:Nil queue:NULL usingBlock:^(NSNotification *note) {
            NSLog(@"Device available! %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
			[self openConnectionButton:self];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
            NSLog(@"Device conncetion open! %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
			[self setUIConnected:YES];
        }];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidFailOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
            NSLog(@"Device conncetion failed with error: %d, device: %@", [(NSNumber *)([note userInfo][PLTDeviceConnectionErrorNotificationKey]) intValue],
				  (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
			self.device = nil;
			[self setUIConnected:NO];
        }];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidCloseConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
            NSLog(@"Device conncetion closed! %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
			self.device = nil;
			[self setUIConnected:NO];
        }];
		
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
	[self setUIConnected:NO];
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
    NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

@end
