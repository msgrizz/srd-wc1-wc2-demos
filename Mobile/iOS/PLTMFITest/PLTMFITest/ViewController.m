//
//  ViewController.m
//  PLTMFITest
//
//  Created by Morgan Davis on 8/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"
#import "UIView+Toast.h"


@interface PLTDLogger
+ (PLTDLogger *)sharedLogger;
@property(nonatomic,assign) NSInteger level;
@end


@interface ViewController () <PLTDeviceSubscriber, UIActionSheetDelegate, UITextViewDelegate>

- (IBAction)openConnectionButton:(id)sender;
//- (IBAction)calibrateButton:(id)sender;
- (IBAction)logLevelButton:(id)sender;
- (IBAction)logClearButton:(id)sender;
- (void)setUIConnected:(BOOL)flag;
- (void)log:(NSString *)format, ...;
- (void)checkLogLevel;

@property(nonatomic,strong)	  PLTDevice					*device;
@property(nonatomic,strong)	  IBOutlet UIButton			*openConnectionButton;
//@property(nonatomic,strong)	  IBOutlet UIButton			*calibrateButton;
@property(nonatomic,strong)	  IBOutlet UIProgressView	*headingProgressView;
@property(nonatomic,strong)	  IBOutlet UIProgressView	*pitchProgressView;
@property(nonatomic,strong)	  IBOutlet UIProgressView	*rollProgressView;
@property(nonatomic,strong)	  IBOutlet UILabel			*headingLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*pitchLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*rollLabel;
@property(nonatomic,strong)	  IBOutlet UITextView		*logTextView;
@property(nonatomic,strong)	  IBOutlet UIButton			*logLevelButton;

@end


@implementation ViewController

#pragma mark - Private

- (IBAction)openConnectionButton:(id)sender
{
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		NSError *err = nil;
		[self.device openConnection:&err];
		if (err) {
			[self log:@"Error opening connection: %@", err];
		}
	}
	else {
		[self log:@"No available devices."];
	}
}

//- (IBAction)calibrateButton:(id)sender
//{
//	// "zero" orientation tracking to current position
//	NSError *err = nil;
//	[self.device setCalibration:nil forService:PLTServiceOrientationTracking error:&err];
//	if (err) {
//		[self log:@"Error calibrating orientation tracking: %@", err];
//	}
//	
//	// the above is equivelent to:
//	// PLTOrientationTrackingInfo *oldOrientationInfo = (PLTOrientationTrackingInfo *)[self.device cachedInfoForService:PLTServiceOrientationTracking error:nil];
//	// PLTOrientationTrackingCalibration *orientationCal = [PLTOrientationTrackingCalibration calibrationWithReferenceOrientationTrackingInfo:oldOrientationInfo];
//	// [self.device setCalibration:orientationCal forService:PLTServiceOrientationTracking error:&err];
//}

- (IBAction)logLevelButton:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Log Level" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
					   otherButtonTitles:@"Trace", @"Debug", @"Info", @"Warn", @"Error", nil];
	[actionSheet showInView:self.view];
}

- (IBAction)logClearButton:(id)sender
{
	self.logTextView.text = @"";
}

- (void)setUIConnected:(BOOL)flag
{
	//[self.calibrateButton setEnabled:flag];
	
	if (!flag) {
		self.headingProgressView.progress = 0;
		self.pitchProgressView.progress = 0;
		self.rollProgressView.progress = 0;
		self.headingLabel.text = @"0˚";
		self.pitchLabel.text = @"0˚";
		self.rollLabel.text = @"0˚";
		self.openConnectionButton.enabled = YES;
		//self.calibrateButton.enabled = NO;
	}
	else {
		self.openConnectionButton.enabled = NO;
		//self.calibrateButton.enabled = YES;
	}
}

- (void)log:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	//NSLogv(format, args);
	self.logTextView.text = [self.logTextView.text stringByAppendingString:[NSString stringWithFormat:@"❯ %@\n",[[NSString alloc] initWithFormat:format arguments:args]]];
	va_end(args);
	
	// strim and scroll log
	if ([self.logTextView.text length] >= 2000) {
		self.logTextView.text = [self.logTextView.text substringFromIndex:1000];
	}
	
	[self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
}

- (void)checkLogLevel
{
	NSString *title = nil;
	switch ([PLTDLogger sharedLogger].level) {
		case 0:
			title = @"Trace";
			break;
		case 1:
			title = @"Debug";
			break;
		case 2:
			title = @"Info";
			break;
		case 3:
			title = @"Warn";
			break;
		case 4:
			title = @"Error";
			break;
		default:
			break;
	}
	
	if (title) {
		[self.logLevelButton setTitle:title forState:UIControlStateNormal];
		[self.logLevelButton setTitle:title forState:UIControlStateHighlighted];
	}
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	pb.string = textView.text;
	
	[self.view makeToast:@"Copied." 
				duration:2.0
				position:@"center"];
	
	return NO;
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
		
		[self.headingProgressView setProgress:(eulerAngles.x + 180.0)/360.0 animated:YES];
		[self.pitchProgressView setProgress:(eulerAngles.y + 90.0)/180.0 animated:YES];
		[self.rollProgressView setProgress:(eulerAngles.z + 180.0)/360.0 animated:YES];
		
		self.headingLabel.text = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.x)];
		self.pitchLabel.text = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.y)];
		self.rollLabel.text = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.z)];
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	//NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		[PLTDLogger sharedLogger].level = buttonIndex;
	}
	
	[self checkLogLevel];
	
	[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
     
#pragma mark - UIViewContorller

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// connection open
	[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		//[self log:@"Device conncetion open: %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey])];
		[self log:@"Device conncetion open: %p", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey])];
		
		[self setUIConnected:YES];
		
		NSError *err = nil;
		
		[self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) [self log:@"Error subscribing to orientation tracking service: %@", err];
		
		[self.device setCalibration:nil forService:PLTServiceOrientationTracking error:&err];
		if (err) [self log:@"Error calibrating orientation tracking: %@", err];
	}];
	
	// connection failed
	[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidFailOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
		NSInteger error = [(NSNumber *)([note userInfo][PLTDeviceConnectionErrorNotificationKey]) intValue];
		
		[self log:@"Device conncetion failed with error: %ld, device: %@", (long)error, device];
		
		self.device = nil;
		[self setUIConnected:NO];
	}];
	
	// connection closed
	[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidCloseConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
		
		if ([device isEqual:self.device]) {
			//[self log:@"Device conncetion closed: %@", device];
			[self log:@"Device conncetion closed: %p", device];
			self.device = nil;
			[self setUIConnected:NO];
		}
	}];
	
	// new device available
	[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceAvailableNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
		PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
		//[self log:@"New device available: %@", device];
		[self log:@"New device available: %p", device];
	}];

	// new log message
	[PLTDLogger sharedLogger].level = 0;
	[self checkLogLevel];
	[[NSNotificationCenter defaultCenter] addObserverForName:@"com.plantronics.dlog" object:nil queue:NULL usingBlock:^(NSNotification *note) {
		static int counter = 0;
		counter ++;
		//[self log:[NSString stringWithFormat:@"[%d]",counter]];
		[self log:[note userInfo][@"message"]];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.logTextView.text = @"";
	self.logTextView.font = [UIFont fontWithName:@"Menlo" size:10];
	[self setUIConnected:NO];
}

@end
