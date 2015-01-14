//
//  SensorsViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/15/13.
//  Copyright (c) 2013 Cambridge Silicon Radio. All rights reserved.
//

#import "SensorsViewController.h"
#import "ConfigTempViewController.h"
#import "PLTDeviceHandler.h"
#import "PLTContextServer.h"
#import "NSData+Base64.h"
#import "StatusWatcher.h"
#import "AppDelegate.h"
//#import "TestFlight.h"
#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
#import "NSData+HexStrings.h"


#define MAX_TABLE_UPDATE_RATE	40.0 // Hz


typedef enum {
    PLTSensorTableRowOrientation,
	PLTSensorTableRowWearingState,
	PLTSensorTableRowLocalProximity,
	PLTSensorTableRowRemoteProximity,
    //PLTSensorTableRowTemperature,
	PLTSensorTableRowPedometer,
    PLTSensorTableRowFreeFall,
    PLTSensorTableRowTaps,
	PLTSensorTableRowHeading,
	PLTSensorTableRowAcceleration,
	PLTSensorTableRowAngularVelocity,
	PLTSensorTableRowMagnetism,
    PLTSensorTableRowMagCal,
    PLTSensorTableRowGyroCal,
	PLTSensorTableRowHSFWVersion,
	PLTSensorTableRowHSHWVersion,
	PLTSensorTableRowAppVersion,
	PLTSensorTableRowPacketData
} PLTSensorTableRow;


@interface SensorsViewController () <PLTDeviceSubscriber, PLTContextServerDelegate>

- (void)subscribeToServices;
- (void)unsubscribeFromServices;
- (void)calOrientation;
- (void)resetPed:(id)sender;
- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)deviceWillSendDataNotification:(NSNotification *)note;
- (void)deviceDidReceiveDataNotification:(NSNotification *)note;

//@property(nonatomic,strong) IBOutlet UITableView        *tableView;
@property(nonatomic,strong) IBOutlet UITableViewCell    *rotationCell;
@property(nonatomic,strong) IBOutlet UIProgressView     *headingProgressView;
@property(nonatomic,strong) IBOutlet UIProgressView     *rollProgressView;
@property(nonatomic,strong) IBOutlet UIProgressView     *pitchProgressView;
@property(nonatomic,strong) IBOutlet UILabel            *headingTitleLabel;
@property(nonatomic,strong) IBOutlet UILabel            *rollTitleLabel;
@property(nonatomic,strong) IBOutlet UILabel            *pitchTitleLabel;
@property(nonatomic,strong) IBOutlet UILabel            *headingValueLabel;
@property(nonatomic,strong) IBOutlet UILabel            *rollValueLabel;
@property(nonatomic,strong) IBOutlet UILabel            *pitchValueLabel;
//@property(nonatomic,strong) IBOutlet UINavigationBar    *navBar;
@property(nonatomic,strong) UILabel						*packetDataLabel;

@end


@implementation SensorsViewController

#pragma mark - Private

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (d) {
		NSError *err = nil;
		
//		[d subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to proximity service: %@", err);
		
		[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
		
		[d subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to pedometer service: %@", err);
		
		[d subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to free fall service: %@", err);
		
		[d subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to taps service: %@", err);
		
		[d subscribe:self toService:PLTServiceMagnetometerCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to magnetometer calibration service: %@", err);
		
//		[d subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
//		if (err) NSLog(@"Error subscribing to gyroscope calibration service: %@", err);
		
		// WC2
		
		[d subscribe:self toService:PLTServiceAcceleration withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceAngularVelocity withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceMagnetism withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceHeading withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		// query those that don't update often
		
		[d queryInfo:self forService:PLTServiceWearingState error:&err];
		if (err) NSLog(@"Error querying wearing state service: %@", err);
		
		[d queryInfo:self forService:PLTServicePedometer error:&err];
		if (err) NSLog(@"Error querying pedometer service: %@", err);
		
		[d queryInfo:self forService:PLTServiceMagnetometerCalibrationStatus error:&err];
		if (err) NSLog(@"Error querying magnetometer calibration service: %@", err);
		
		[d queryInfo:self forService:PLTServiceGyroscopeCalibrationStatus error:&err];
		if (err) NSLog(@"Error querying gyroscope calibration service: %@", err);
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

- (void)calOrientation
{
	[CONNECTED_DEVICE setCalibration:nil forService:PLTServiceOrientation error:nil];
}

- (void)resetPed:(id)sender
{
    //self.pedStepOffset = self.pedCount;
	[CONNECTED_DEVICE setCalibration:nil forService:PLTServicePedometer error:nil];
	[self.tableView reloadData];
}

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self subscribeToServices];
}

- (void)deviceWillSendDataNotification:(NSNotification *)note
{
	NSData *data = (NSData *)note.userInfo[PLTDeviceDataNotificationKey];
	NSString *hexString = [data hexStringWithSpaceEvery:2];
	self.packetDataLabel.text = [NSString stringWithFormat:@"--> %@", hexString];
}

- (void)deviceDidReceiveDataNotification:(NSNotification *)note
{
	NSData *data = (NSData *)note.userInfo[PLTDeviceDataNotificationKey];
	NSString *hexString = [data hexStringWithSpaceEvery:2];
	self.packetDataLabel.text = [NSString stringWithFormat:@"<-- %@", hexString];
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
		
		NSInteger heading = lroundf(eulerAngles.x);
		NSInteger pitch = lroundf(eulerAngles.y);
		NSInteger roll = lroundf(eulerAngles.z);
		
		BOOL animateProgressIndicators = NO;
		
		//NSInteger heading = self.heading;
		if (heading < -180) heading = (heading+360)%180;
		if (heading > 180) heading = (heading-360)%180;
		// turn the int into a float between 0.0 and 1.0 and update the heading scale
		float fl_head = (heading+180) / 360.0;
		[self.headingProgressView setProgress:fl_head animated:animateProgressIndicators];
		self.headingValueLabel.text = [NSString stringWithFormat:@"%d°",heading];
		
		//NSInteger roll = self.roll;
		if (roll < -180) roll = (roll+360)%180;
		if (roll > 180) roll = (roll-360)%180;
		// turn the int into a float between 0.0 and 1.0 and update the roll scale
		float fl_roll = ((roll) +180)/ 360.0;
		[self.rollProgressView setProgress:fl_roll animated:animateProgressIndicators];
		self.rollValueLabel.text = [NSString stringWithFormat:@"%d°",roll];
		
		//NSInteger pitch = self.pitch;
		if (pitch < -180) pitch = (pitch+360)%180;
		if (pitch > 180) pitch = (pitch-360)%180;
		// turn the int into a float between 0.0 and 1.0 and update the pitch scale
		float fl_pitch = ((pitch) +90)/ 180.0;
		[self.pitchProgressView setProgress:fl_pitch animated:animateProgressIndicators];
		self.pitchValueLabel.text = [NSString stringWithFormat:@"%d°",pitch];
	}
	else {
		[self.tableView reloadData];
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PLTSensorTableRowPacketData + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    
    if (indexPath.row == PLTSensorTableRowOrientation) {
        cell = self.rotationCell;
        if (IOS7) {
            UIColor *color = [UIColor colorWithRed:0.0/255.0 green:127.0/255.0 blue:255.0/248.0 alpha:1.0];
            self.headingTitleLabel.textColor = color;
            self.pitchTitleLabel.textColor = color;
            self.rollTitleLabel.textColor = color;
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"plain_auxcell"];
        if (cell == nil) {
			if (IPAD) {
				cell = [[ExtendedLabelWidthTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain_auxcell"];
				cell.textLabel.font = [UIFont systemFontOfSize:28];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
				cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                CGRect frame = cell.detailTextLabel.frame;
//                frame.size.height += 8;
//                frame.origin.y -= 4;
//                cell.detailTextLabel.frame = frame;
			}
			else {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain_auxcell"];
			}
        }
		
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
        
        switch (indexPath.row) {
			case PLTSensorTableRowWearingState: {
				cell.textLabel.text = @"wearing state";
				NSString *state = @"";
				PLTWearingStateInfo *wearInfo = (PLTWearingStateInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceWearingState error:nil];
				if (wearInfo.isBeingWorn) state = @"Wearing";
				else state = @"Not Wearing";
                cell.detailTextLabel.text = state;
				break; }
				
//            case PLTSensorTableRowTemperature:
//                cell.textLabel.text = @"temperature";
//				float celciusOffset = [DEFAULTS floatForKey:PLTDefaultsKeyTemperatureOffsetCelcius];
//                float temp_c_calibrated = self.temp;
//                if (celciusOffset != FLT_MIN) {
//                    temp_c_calibrated += celciusOffset;
//                }
//				BOOL celciusMetric = [DEFAULTS boolForKey:PLTDefaultsKeyMetricUnits];
//                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld° %@",
//                                             (celciusMetric ? lroundf(temp_c_calibrated) : lroundf((temp_c_calibrated)*9.0/5.0+32.0)),
//											 (celciusMetric ? @"C" : @"F")];
//                break;
				
			case PLTSensorTableRowLocalProximity: {
				cell.textLabel.text = @"local proximity";
				PLTProximityInfo *proximityInfo = (PLTProximityInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceProximity error:nil];
				if (proximityInfo) { 
					cell.detailTextLabel.text = [NSStringFromProximity(proximityInfo.localProximity) capitalizedString];
				}
				else {
					cell.detailTextLabel.text = @"-";
				}
				break; }
				
			case PLTSensorTableRowRemoteProximity: {
				cell.textLabel.text = @"remote proximity";
				PLTProximityInfo *proximityInfo = (PLTProximityInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceProximity error:nil];
				if (proximityInfo) { 
					cell.detailTextLabel.text = [NSStringFromProximity(proximityInfo.remoteProximity) capitalizedString];
				}
				else {
					cell.detailTextLabel.text = @"-";
				}
				break; }
				
			case PLTSensorTableRowFreeFall: {
                cell.textLabel.text = @"free fall";
				PLTFreeFallInfo *freeFallInfo = (PLTFreeFallInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceFreeFall error:nil];
				BOOL freeFall = freeFallInfo.isInFreeFall;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",(freeFall?@"Yes":@"No")];
                cell.detailTextLabel.textColor = (freeFall ? [UIColor redColor] : [UIColor blackColor]);
				break; }
				
            case PLTSensorTableRowPedometer: {
                cell.textLabel.text = @"pedometer";
				PLTPedometerInfo *pedometerInfo = (PLTPedometerInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServicePedometer error:nil];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d steps",pedometerInfo.steps];
                break; }
				
            case PLTSensorTableRowTaps: {
                cell.textLabel.text = @"taps";
				PLTTapsInfo *tapsInfo = (PLTTapsInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceTaps error:nil];
                if (tapsInfo.count) {
                    NSString *tapDirStr = [NSStringFromTapDirection(tapsInfo.direction) capitalizedString];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@, %@",tapsInfo.count,(tapsInfo.count==1 ? @"Tap" : @"Taps"),tapDirStr];
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                }
                else {
                    cell.detailTextLabel.text = @"-";
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                }
                break; }
				
			case PLTSensorTableRowMagCal: {
				cell.textLabel.text = @"magnetometer";
				PLTMagnetometerCalibrationInfo	*magCalInfo = (PLTMagnetometerCalibrationInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceMagnetometerCalibrationStatus error:nil];
				NSString *magCalStr = nil;
				UIColor *color = [UIColor blackColor];
				if (magCalInfo.isCalibrated) {
					magCalStr = @"Calibrated";
					color = [UIColor colorWithRed:0 green:(150.0/256.0) blue:0 alpha:1.0];
				}
				else {
					magCalStr = @"Not Calibrated";
					color = [UIColor redColor];
				}
				cell.detailTextLabel.text = magCalStr;
				cell.detailTextLabel.textColor = color;
				break; }
				
			case PLTSensorTableRowGyroCal: {
                cell.textLabel.text = @"gyroscope";
				PLTGyroscopeCalibrationInfo	*gyroCalInfo = (PLTGyroscopeCalibrationInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceGyroscopeCalibrationStatus error:nil];
				NSString *gyroCalStr = nil;
				UIColor *color = [UIColor blackColor];
				if (gyroCalInfo.isCalibrated) {
					gyroCalStr = @"Calibrated";
					color = [UIColor colorWithRed:0 green:(150.0/256.0) blue:0 alpha:1.0];
				}
				else {
					gyroCalStr = @"Not Calibrated";
					color = [UIColor redColor];
				}
				cell.detailTextLabel.text = gyroCalStr;
                cell.detailTextLabel.textColor = color;
				break; }
				
			case PLTSensorTableRowAppVersion: {
                cell.textLabel.text = @"app version";
                cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
				break; }
				
			case PLTSensorTableRowHSFWVersion: {
                cell.textLabel.text = @"headset FW vers";
				if (CONNECTED_DEVICE.firmwareVersion) {
					cell.detailTextLabel.text = CONNECTED_DEVICE.firmwareVersion;
				}
				else {
					cell.detailTextLabel.text = @"-";
				}
				break; }
				
			case PLTSensorTableRowHSHWVersion: {
				cell.textLabel.text = @"headset HW vers";
				if (CONNECTED_DEVICE.hardwareVersion) {
					cell.detailTextLabel.text = CONNECTED_DEVICE.hardwareVersion;
				}
				else {
					cell.detailTextLabel.text = @"-";
				}
				break; }
				
			case PLTSensorTableRowPacketData: {
				cell.textLabel.text = @"packet data";
				cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
				//cell.detailTextLabel.minimumScaleFactor = 2.0;
				self.packetDataLabel = cell.detailTextLabel;
//				NSMutableString *hexStr = [NSMutableString string];
//				for (int i = 0; i < [self.packetData length]; i++) [hexStr appendFormat:@"%02x", ((uint8_t*)[self.packetData bytes])[i]];
//				cell.detailTextLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:12];
//				cell.detailTextLabel.text = hexStr;
				if (![cell.detailTextLabel.text length]) {
					cell.detailTextLabel.text = @"-";
				}
				break; }
				
			case PLTSensorTableRowHeading: {
				cell.textLabel.text = @"heading";
				break; }
				
			case PLTSensorTableRowAcceleration: {
				cell.textLabel.text = @"acceleration";
				break; }
				
			case PLTSensorTableRowAngularVelocity: {
				cell.textLabel.text = @"angular v.";
				break; }
				
			case PLTSensorTableRowMagnetism: {
				cell.textLabel.text = @"magnetism";
				break; }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == PLTSensorTableRowOrientation) {
		if (IPAD) {
			return 126;
		}
		else {
			return 76;
		}
    }
    else {
		if (IPAD) {
			return 56;
		}
		else {
			return 44;
		}
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
		case PLTSensorTableRowOrientation:
        case PLTSensorTableRowPedometer:
        //case PLTSensorTableRowTemperature:
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
		case PLTSensorTableRowOrientation:
			[self calOrientation];
			break;
        case PLTSensorTableRowPedometer:
            [self resetPed:tableView];
            break;
//        case PLTSensorTableRowTemperature:
//            [self configTemp:tableView];
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
//	if (!HEADSET_CONNECTED) {
//		if ([message hasType:@"event"]) {
//			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
//				NSDictionary *info = [[PLTDeviceHandler sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
//				if (info) {
//					[self headsetInfoDidUpdate:info];
//				}
//			}
//		}
//	}
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        if (IOS7) self = [super initWithNibName:@"SensorsViewController_iOS7" bundle:nibBundleOrNil];
        else self = [super initWithNibName:@"SensorsViewController" bundle:nibBundleOrNil];
    else
        self = [super initWithNibName:@"SensorsViewController_iPad" bundle:nibBundleOrNil];
    
    self.tabBarItem.title = @"Sensors";
    //self.tabBarItem.image = [UIImage imageNamed:@"diode_icon.png"];
    self.tabBarItem.image = [UIImage imageNamed:@"signal_icon.png"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_ios7.png"];//[UIImage imageNamed:@"plt_logo_nav.png"];
	if (!IOS7) pltImage = [UIImage imageNamed:@"pltlabs_nav.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeCenter;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																   style:UIBarButtonItemStyleBordered
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = actionItem;
    
    [self resetPed:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
#warning navBar
	[[StatusWatcher sharedWatcher] setActiveNavigationBar:self.navigationController.navigationBar animated:NO];
    
    [[PLTContextServer sharedContextServer] addDelegate:self];
    
	[self subscribeToServices];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceWillSendDataNotification:) name:PLTDeviceWillSendDataNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidReceiveDataNotification:) name:PLTDeviceDidReceiveDataNotification object:nil];

    //[TestFlight passCheckpoint:@"SENSORS_TAB"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PLTContextServer sharedContextServer] removeDelegate:self];
	
	[self unsubscribeFromServices];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceWillSendDataNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceDidReceiveDataNotification object:nil];
}

@end


#pragma mark - ExtendedLabelWidthTableViewCell

@implementation ExtendedLabelWidthTableViewCell

- (void)layoutSubviews
{
	[super layoutSubviews]; // lays out the cell as UITableViewCellStyleValue2 would normally look like

	CGRect frame = self.textLabel.frame;
	frame.size.width += 128;
	self.textLabel.frame = frame;
    
    CGFloat xSpace = (IPAD ? 32 : 20);
	
	CGFloat x = frame.origin.x + frame.size.width + xSpace;
	frame = CGRectMake(x, 17, 256, 22);
	self.detailTextLabel.frame = frame;
}

@end

