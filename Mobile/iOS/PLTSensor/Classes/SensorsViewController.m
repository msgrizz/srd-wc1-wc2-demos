//
//  SensorsViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/15/13.
//  Copyright (c) 2013 Cambridge Silicon Radio. All rights reserved.
//

#import "SensorsViewController.h"
#import "ConfigTempViewController.h"
#import "PLTHeadsetManager.h"
#import "PLTContextServer.h"
#import "NSData+Base64.h"
#import "StatusWatcher.h"
#import "AppDelegate.h"


#define MAX_TABLE_UPDATE_RATE	40.0 // Hz


typedef enum {
    PLTSensorTableRowRotation,
	PLTSensorTableRowWearingState,
    //PLTSensorTableRowTemperature,
    PLTSensorTableRowFreeFall,
    PLTSensorTableRowPedometer,
    PLTSensorTableRowTaps,
    //PLTSensorTableRowMagCal,
    PLTSensorTableRowGyroCal,
	PLTSensorTableRowAppVersion,
	PLTSensorTableRowHeadsetVersion,
	PLTSensorTableRowPacketData
} PLTSensorTableRow;


@interface SensorsViewController () <PLTContextServerDelegate>//, ConfigTempViewControllerDelegate>

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note;
- (void)headsetInfoDidUpdate:(NSDictionary *)info;
//- (void)updateTimer:(NSTimer *)aTimer;
- (void)resetPed:(id)sender;
//- (void)configTemp:(id)sender;

@property(nonatomic,assign) NSInteger                           temp;
@property(nonatomic,assign) BOOL                                freeFall;
@property(nonatomic,assign) NSUInteger                          pedCount;
@property(nonatomic,assign) PLTTapDirection                     tapDir;
@property(nonatomic,assign) NSUInteger                          tapCount;
@property(nonatomic,assign) PLTMagnetometerCalibrationStatus    magCal;
@property(nonatomic,assign) PLTGyroscopeCalibrationStatus       gyroCal;
@property(nonatomic,assign) NSUInteger                          majVers;
@property(nonatomic,assign) NSUInteger                          minVers;
@property(nonatomic,assign) NSInteger                           roll;
@property(nonatomic,assign) NSInteger                           pitch;
@property(nonatomic,assign) NSInteger                           heading;
@property(nonatomic,assign) NSUInteger                          pedStepOffset;
@property(nonatomic,strong) NSData								*packetData;
@property(nonatomic,assign) BOOL								isDonned;
//@property(nonatomic,strong) NSTimer                             *updateTimer;
@property(nonatomic,strong) NSDate								*lastTableUpdateDate;

//@property(nonatomic,assign) BOOL                                celciusMetric;
//@property(nonatomic,assign) float                               celciusOffset;

@end


@implementation SensorsViewController

#pragma mark - Private

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
	[self headsetInfoDidUpdate:userInfo];
}

- (void)headsetInfoDidUpdate:(NSDictionary *)info
{
	self.temp = [info[PLTHeadsetInfoKeyTemperature] integerValue];
    self.freeFall = [info[PLTHeadsetInfoKeyFreeFall] boolValue];
    self.pedCount = [info[PLTHeadsetInfoKeyPedometerCount] unsignedIntegerValue];
    self.tapDir = [info[PLTHeadsetInfoKeyTapDirection] unsignedIntegerValue];
    self.tapCount = [info[PLTHeadsetInfoKeyTapCount] unsignedIntegerValue];
    self.magCal = [info[PLTHeadsetInfoKeyMagnetometerCalibrationStatus] unsignedIntegerValue];
    self.gyroCal = [info[PLTHeadsetInfoKeyGyroscopeCalibrationStatus] unsignedIntegerValue];
    self.majVers = [info[PLTHeadsetInfoKeyMajorVersion] unsignedIntegerValue];
    self.minVers = [info[PLTHeadsetInfoKeyMinorVersion] unsignedIntegerValue];
	self.packetData = info[PLTHeadsetInfoKeyPacketData];
	self.isDonned = [(NSNumber *)info[PLTHeadsetInfoKeyIsDonned] boolValue];
	
	Vec3 rotationVector;
    NSData *rotationData = [info objectForKey:PLTHeadsetInfoKeyRotationVectorData];
    [rotationData getBytes:&rotationVector length:[rotationData length]];
	
    self.heading = lroundf(rotationVector.x);
    self.pitch = lroundf(rotationVector.y);
    self.roll = lroundf(rotationVector.z);
	
	BOOL animateProgressIndicators = NO;
    
    NSInteger heading = self.heading;
    if (heading < -180) heading = (heading+360)%180;
    if (heading > 180) heading = (heading-360)%180;
    // turn the int into a float between 0.0 and 1.0 and update the heading scale
    float fl_head = (heading+180) / 360.0;
    [self.headingProgressView setProgress:fl_head animated:animateProgressIndicators];
    self.headingValueLabel.text = [NSString stringWithFormat:@"%d°",heading];
    
    NSInteger roll = self.roll;
    if (roll < -180) roll = (roll+360)%180;
    if (roll > 180) roll = (roll-360)%180;
    // turn the int into a float between 0.0 and 1.0 and update the roll scale
    float fl_roll = ((roll) +180)/ 360.0;
    [self.rollProgressView setProgress:fl_roll animated:animateProgressIndicators];
    self.rollValueLabel.text = [NSString stringWithFormat:@"%d°",roll];
	
    NSInteger pitch = self.pitch;
    if (pitch < -180) pitch = (pitch+360)%180;
    if (pitch > 180) pitch = (pitch-360)%180;
    // turn the int into a float between 0.0 and 1.0 and update the pitch scale
    float fl_pitch = ((pitch) +90)/ 180.0;
    [self.pitchProgressView setProgress:fl_pitch animated:animateProgressIndicators];
    self.pitchValueLabel.text = [NSString stringWithFormat:@"%d°",pitch];
	
	NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:self.lastTableUpdateDate];
	if (!self.lastTableUpdateDate || (gap > (1.0/MAX_TABLE_UPDATE_RATE))) {
		[self.tableView reloadData];
		self.lastTableUpdateDate = [NSDate date];
	}
}

//- (void)updateTimer:(NSTimer *)aTimer
//{
//    [self.tableView reloadData];
//}

- (void)resetPed:(id)sender
{
    self.pedStepOffset = self.pedCount;
}

//- (void)configTemp:(id)sender
//{
//    ConfigTempViewController *controller = [[ConfigTempViewController alloc] initWithNibName:nil bundle:nil];
//    controller.delegate = self;
//    controller.celciusMetric = self.celciusMetric;
//    if (self.celciusOffset != FLT_MIN) controller.ambientTempCelcius = self.temp + self.celciusOffset;
//    else controller.ambientTempCelcius = self.temp;
//    [self presentViewController:controller animated:YES completion:nil];
//}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PLTSensorTableRowPacketData + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    
    if (indexPath.row == PLTSensorTableRowRotation) {
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
			if (DEVICE_IPAD) {
				cell = [[ExtendedLabelWidthTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain_auxcell"];
				cell.textLabel.font = [UIFont systemFontOfSize:28];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
//                CGRect frame = cell.detailTextLabel.frame;
//                frame.size.height += 8;
//                frame.origin.y -= 4;
//                cell.detailTextLabel.frame = frame;
			}
			else {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain_auxcell"];
			}
        }
        
        switch (indexPath.row) {
			case PLTSensorTableRowWearingState: {
				cell.textLabel.text = @"wearing state";
				NSString *state = @"";
				if (self.isDonned) state = @"Wearing";
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
            case PLTSensorTableRowFreeFall:
                cell.textLabel.text = @"free fall?";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",(self.freeFall?@"Yes":@"No")];
                cell.detailTextLabel.textColor = (self.freeFall ? [UIColor redColor] : [UIColor grayColor]);
                break;
            case PLTSensorTableRowPedometer: {
                cell.textLabel.text = @"pedometer";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d steps",self.pedCount - self.pedStepOffset];
                
                static UIButton *clearButton = nil;
                if (!clearButton) clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) clearButton.frame = CGRectMake(241, 5, 64, 34);
				else clearButton.frame = CGRectMake(tableView.frame.size.width - 64 - 14, 12, 64, 34);
                [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
                clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
                [clearButton addTarget:self action:@selector(resetPed:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:clearButton];
                
                break; }
            case PLTSensorTableRowTaps: {
                cell.textLabel.text = @"taps";
                if (self.tapCount) {
                    NSString *tapDirStr = nil;
                    switch (self.tapDir) {
                        case PLTTapDirectionXUp:
                            tapDirStr = @", X Up";
                            break;
                        case PLTTapDirectionXDown:
                            tapDirStr = @", X Down";
                            break;
                        case PLTTapDirectionYUp:
                            tapDirStr = @", Y Up";
                            break;
                        case PLTTapDirectionYDown:
                            tapDirStr = @", Y Down";
                            break;
                        case PLTTapDirectionZUp:
                            tapDirStr = @", Z Up";
                            break;
                        case PLTTapDirectionZDown:
                            tapDirStr = @", Z Down";
                            break;
                        default:
                            break;
                    }
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@%@",self.tapCount,(self.tapCount==1 ? @"tap" : @"taps"),tapDirStr];
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                }
                else {
                    cell.detailTextLabel.text = @"-";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                }
                break; }
//            case PLTSensorTableRowMagCal: {
//                cell.textLabel.text = @"magnetometer";
//				cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                NSString *magCalStr = nil;
//                UIColor *color = [UIColor blackColor];
//                switch (self.magCal) {
//                    case PLTMagnetometerCalibrationStatusNotCalibrated:
//                        magCalStr = @"Not Calibrated";
//                        color = [UIColor redColor];
//                        break;
//                    case PLTMagnetometerCalibrationStatusCalibrating1:
//                    case PLTMagnetometerCalibrationStatusCalibrating2:
//                        magCalStr = [NSString stringWithFormat:@"%d",self.magCal];
//                        color = [UIColor orangeColor];
//                        break;
//                    case PLTMagnetometerCalibrationStatusCalibrated:
//                        magCalStr = @"Calibrated";
//                        color = [UIColor colorWithRed:0 green:(127.0/256.0) blue:0 alpha:1.0];
//                        break;
//                    default:
//                        break;
//                }
//                cell.detailTextLabel.text = magCalStr;
//                cell.detailTextLabel.textColor = color;
//                break; }
            case PLTSensorTableRowGyroCal: {
                cell.textLabel.text = @"gyroscope";
                NSString *gyroCalStr = nil;
                UIColor *color = [UIColor blackColor];
                switch (self.gyroCal) {
                    case PLTGyroscopeCalibrationStatusNotCalibrated:
                        gyroCalStr = @"Not Calibrated";
                        color = [UIColor redColor];
                        break;
                    case PLTGyroscopeCalibrationStatusCalibrating1:
                    case PLTGyroscopeCalibrationStatusCalibrating2:
                        gyroCalStr = [NSString stringWithFormat:@"%d",self.gyroCal];
                        color = [UIColor orangeColor];
                        break;
                    case PLTGyroscopeCalibrationStatusCalibrated:
                        gyroCalStr = @"Calibrated";
                        color = [UIColor colorWithRed:0 green:(150.0/256.0) blue:0 alpha:1.0];
                        break;
                    default:
                        break;
                }
                cell.detailTextLabel.text = gyroCalStr;
                cell.detailTextLabel.textColor = color;
                break; }
			case PLTSensorTableRowAppVersion:
                cell.textLabel.text = @"app version";
                cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                break;
			case PLTSensorTableRowHeadsetVersion:
                cell.textLabel.text = @"headset version";
				cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.%d",self.majVers,self.minVers];
                break;
            case PLTSensorTableRowPacketData: {
				cell.textLabel.text = @"packet data";
				NSMutableString *hexStr = [NSMutableString string];
				for (int i = 0; i < [self.packetData length]; i++) [hexStr appendFormat:@"%02x", ((uint8_t*)[self.packetData bytes])[i]];
				cell.detailTextLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:12];
				cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
				cell.detailTextLabel.text = hexStr;
				break; }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == PLTSensorTableRowRotation) {
		if (DEVICE_IPAD) {
			return 126;
		}
		else {
			return 76;
		}
    }
    else {
		if (DEVICE_IPAD) {
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
	if (!HEADSET_CONNECTED) {
		if ([message hasType:@"event"]) {
			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
				NSDictionary *info = [[PLTHeadsetManager sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
				if (info) {
					[self headsetInfoDidUpdate:info];
				}
			}
		}
	}
}

//#pragma mark - ConfigTempViewControllerDelegate
//
//- (void)configTempViewController:(ConfigTempViewController *)controller didAcceptMetric:(BOOL)celcius ambientTemp:(float)ambientTempCelcius
//{
//    self.celciusMetric = celcius;
//    self.celciusOffset = ambientTempCelcius - self.temp;
//    [self.tableView reloadData];
//    
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)configTempViewControllerDidCancel:(ConfigTempViewController *)controller
//{
//    [self dismissModalViewControllerAnimated:YES];
//}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
    //self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/UPDATE_RATE) target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PLTContextServer sharedContextServer] removeDelegate:self];
    
//    if ([self.updateTimer isValid]) {
//        [self.updateTimer invalidate];
//        self.updateTimer = nil;
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PLTHeadsetInfoDidUpdateNotification object:nil];
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
    
    CGFloat xSpace = (DEVICE_IPAD ? 32 : 20);
	
	CGFloat x = frame.origin.x + frame.size.width + xSpace;
	frame = CGRectMake(x, 17, 256, 22);
	self.detailTextLabel.frame = frame;
}

@end

