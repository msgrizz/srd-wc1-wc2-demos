//
//  ViewController.m
//  PLTDeviceExample
//
//  Created by Davis, Morgan on 8/1/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"

#import "AppDelegate.h"


#define MAX_TABLE_UPDATE_RATE		40.0 // Hz
#define DEVICE_IPAD					([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


typedef enum {
    PLTSensorTableRowRotation,
	PLTSensorTableRowWearingState,
    PLTSensorTableRowTemperature,
    PLTSensorTableRowFreeFall,
    PLTSensorTableRowPedometer,
    PLTSensorTableRowTaps,
    PLTSensorTableRowMagCal,
    PLTSensorTableRowGyroCal,
	PLTSensorTableRowAppVersion,
	PLTSensorTableRowHeadsetVersion
} PLTSensorTableRow;


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

- (void)deviceInfoDidUpdateNotification:(NSNotification *)note;
- (void)headsetInfoDidUpdate:(NSDictionary *)info;
- (void)resetPed:(id)sender;

@property(nonatomic,strong) IBOutlet UITableView					*tableView;
@property(nonatomic,strong) IBOutlet UITableViewCell				*rotationCell;
@property(nonatomic,strong) IBOutlet UIProgressView					*headingProgressView;
@property(nonatomic,strong) IBOutlet UIProgressView					*rollProgressView;
@property(nonatomic,strong) IBOutlet UIProgressView					*pitchProgressView;
@property(nonatomic,strong) IBOutlet UILabel						*headingLabel;
@property(nonatomic,strong) IBOutlet UILabel						*rollLabel;
@property(nonatomic,strong) IBOutlet UILabel						*pitchLabel;
@property(nonatomic,strong) IBOutlet UINavigationBar				*navBar;

@property(nonatomic,assign) NSInteger								temp;
@property(nonatomic,assign) BOOL									freeFall;
@property(nonatomic,assign) NSUInteger								pedCount;
@property(nonatomic,assign) PLTDeviceTapDirection					tapDir;
@property(nonatomic,assign) NSUInteger								tapCount;
@property(nonatomic,assign) PLTDeviceMagnetometerCalibrationStatus	magCal;
@property(nonatomic,assign) PLTDeviceGyroscopeCalibrationStatus		gyroCal;
@property(nonatomic,assign) NSUInteger								majVers;
@property(nonatomic,assign) NSUInteger								minVers;
@property(nonatomic,assign) NSInteger								roll;
@property(nonatomic,assign) NSInteger								pitch;
@property(nonatomic,assign) NSInteger								heading;
@property(nonatomic,assign) NSUInteger								pedStepOffset;
@property(nonatomic,assign) BOOL									isDonned;
@property(nonatomic,strong) NSDate									*lastTableUpdateDate;

@end


@implementation ViewController

#pragma mark - Private

- (void)deviceInfoDidUpdateNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
	[self headsetInfoDidUpdate:userInfo];
}

- (void)headsetInfoDidUpdate:(NSDictionary *)info
{
	self.temp = [info[PLTDeviceInfoKeyTemperature] integerValue];
    self.freeFall = [info[PLTDeviceInfoKeyFreeFall] boolValue];
    self.pedCount = [info[PLTDeviceInfoKeyPedometerCount] unsignedIntegerValue];
    self.tapDir = [info[PLTDeviceInfoKeyTapDirection] unsignedIntegerValue];
    self.tapCount = [info[PLTDeviceInfoKeyTapCount] unsignedIntegerValue];
    self.magCal = [info[PLTDeviceInfoKeyMagnetometerCalibrationStatus] unsignedIntegerValue];
    self.gyroCal = [info[PLTDeviceInfoKeyGyroscopeCalibrationStatus] unsignedIntegerValue];
    self.majVers = [info[PLTDeviceInfoKeyMajorVersion] unsignedIntegerValue];
    self.minVers = [info[PLTDeviceInfoKeyMinorVersion] unsignedIntegerValue];
	self.isDonned = [(NSNumber *)info[PLTDeviceInfoKeyIsDonned] boolValue];
	
	Vec3 orientationVector;
    NSData *orientationData = [info objectForKey:PLTDeviceInfoKeyOrientationVectorData];
    [orientationData getBytes:&orientationVector length:[orientationData length]];
	
    self.heading = lroundf(orientationVector.x);
    self.pitch = lroundf(orientationVector.y);
    self.roll = lroundf(orientationVector.z);
	
	BOOL animateProgressIndicators = NO;
    
    NSInteger heading = self.heading;
    if (heading < -180) heading = (heading+360)%180;
    if (heading > 180) heading = (heading-360)%180;
    // turn the int into a float between 0.0 and 1.0 and update the heading scale
    float fl_head = (heading+180) / 360.0;
    [self.headingProgressView setProgress:fl_head animated:animateProgressIndicators];
    self.headingLabel.text = [NSString stringWithFormat:@"%d°",heading];
    
    NSInteger roll = self.roll;
    if (roll < -180) roll = (roll+360)%180;
    if (roll > 180) roll = (roll-360)%180;
    // turn the int into a float between 0.0 and 1.0 and update the roll scale
    float fl_roll = ((roll) +180)/ 360.0;
    [self.rollProgressView setProgress:fl_roll animated:animateProgressIndicators];
    self.rollLabel.text = [NSString stringWithFormat:@"%d°",roll];
	
    NSInteger pitch = self.pitch;
    if (pitch < -180) pitch = (pitch+360)%180;
    if (pitch > 180) pitch = (pitch-360)%180;
    // turn the int into a float between 0.0 and 1.0 and update the pitch scale
    float fl_pitch = ((pitch) +90)/ 180.0;
    [self.pitchProgressView setProgress:fl_pitch animated:animateProgressIndicators];
    self.pitchLabel.text = [NSString stringWithFormat:@"%d°",pitch];
	
	NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:self.lastTableUpdateDate];
	if (!self.lastTableUpdateDate || (gap > (1.0/MAX_TABLE_UPDATE_RATE))) {
		[self.tableView reloadData];
		self.lastTableUpdateDate = [NSDate date];
	}
}

- (void)resetPed:(id)sender
{
    self.pedStepOffset = self.pedCount;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PLTSensorTableRowHeadsetVersion + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    
    if (indexPath.row == PLTSensorTableRowRotation) {
        cell = self.rotationCell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"plain_auxcell"];
        if (cell == nil) {
			if (DEVICE_IPAD) {
				cell = [[ExtendedLabelWidthTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain_auxcell"];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
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
            case PLTSensorTableRowTemperature:
                cell.textLabel.text = @"temperature";
				float celciusOffset = 0; // use for calibration
                float temp_c_calibrated = self.temp;
                if (celciusOffset != FLT_MIN) {
                    temp_c_calibrated += celciusOffset;
                }
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld° F", lroundf((temp_c_calibrated)*9.0/5.0+32.0)];
                break;
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
                        case PLTDeviceTapDirectionXUp:
                            tapDirStr = @", X Up";
                            break;
                        case PLTDeviceTapDirectionXDown:
                            tapDirStr = @", X Down";
                            break;
                        case PLTDeviceTapDirectionYUp:
                            tapDirStr = @", Y Up";
                            break;
                        case PLTDeviceTapDirectionYDown:
                            tapDirStr = @", Y Down";
                            break;
                        case PLTDeviceTapDirectionZUp:
                            tapDirStr = @", Z Up";
                            break;
                        case PLTDeviceTapDirectionZDown:
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
            case PLTSensorTableRowMagCal: {
                cell.textLabel.text = @"magnetometer";
				cell.textLabel.adjustsFontSizeToFitWidth = YES;
                NSString *magCalStr = nil;
                UIColor *color = [UIColor blackColor];
                switch (self.magCal) {
                    case PLTDeviceMagnetometerCalibrationStatusNotCalibrated:
                        magCalStr = @"Not Calibrated";
                        color = [UIColor redColor];
                        break;
                    case PLTDeviceMagnetometerCalibrationStatusCalibrating1:
                    case PLTDeviceMagnetometerCalibrationStatusCalibrating2:
                        magCalStr = [NSString stringWithFormat:@"%d",self.magCal];
                        color = [UIColor orangeColor];
                        break;
                    case PLTDeviceMagnetometerCalibrationStatusCalibrated:
                        magCalStr = @"Calibrated";
                        color = [UIColor colorWithRed:0 green:(127.0/256.0) blue:0 alpha:1.0];
                        break;
                    default:
                        break;
                }
                cell.detailTextLabel.text = magCalStr;
                cell.detailTextLabel.textColor = color;
                break; }
            case PLTSensorTableRowGyroCal: {
                cell.textLabel.text = @"gyroscope";
                NSString *gyroCalStr = nil;
                UIColor *color = [UIColor blackColor];
                switch (self.gyroCal) {
                    case PLTDeviceGyroscopeCalibrationStatusNotCalibrated:
                        gyroCalStr = @"Not Calibrated";
                        color = [UIColor redColor];
                        break;
                    case PLTDeviceGyroscopeCalibrationStatusCalibrating1:
                    case PLTDeviceGyroscopeCalibrationStatusCalibrating2:
                        gyroCalStr = [NSString stringWithFormat:@"%d",self.gyroCal];
                        color = [UIColor orangeColor];
                        break;
                    case PLTDeviceGyroscopeCalibrationStatusCalibrated:
                        gyroCalStr = @"Calibrated";
                        color = [UIColor colorWithRed:0 green:(127.0/256.0) blue:0 alpha:1.0];
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
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == PLTSensorTableRowRotation) {
		if (DEVICE_IPAD) {
			return 108;
		}
		else {
			return 74;
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
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self = [super initWithNibName:@"ViewController_iPhone" bundle:nibBundleOrNil];
    else
        self = [super initWithNibName:@"ViewController_iPad" bundle:nibBundleOrNil];
	
	PLTDeviceManager *dm = [PLTDeviceManager sharedManager];
	dm.headTrackingCalibrationTriggers = PLTDeviceHeadTrackingCalibrationTriggerShake & PLTDeviceHeadTrackingCalibrationTriggerDon;
	dm.donCalibrationDelay = 2.0;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set PLT nav bar image
    UIImage *pltImage = [UIImage imageNamed:@"plt_logo_nav.png"];
    CGRect navFrame = self.navBar.frame;
    CGRect viewFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
                                  (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
                                  pltImage.size.width + 2,
                                  pltImage.size.height + 2);
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:viewFrame];
    view.contentMode = UIViewContentModeCenter;
    view.image = pltImage;
    [self.navBar addSubview:view];
	
    [self resetPed:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoDidUpdateNotification:) name:PLTDeviceInfoDidUpdateNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:PLTDeviceInfoDidUpdateNotification object:nil];
}

@end


#pragma mark - ExtendedLabelWidthTableViewCell

@implementation ExtendedLabelWidthTableViewCell

- (void)layoutSubviews
{
	[super layoutSubviews]; // lays out the cell as UITableViewCellStyleValue2 would normally look like
	
	CGRect frame = self.textLabel.frame;
	frame.size.width += 40;
	self.textLabel.frame = frame;
	
	CGFloat x = frame.origin.x + frame.size.width + 20;
	frame = CGRectMake(x, 17, 256, 22);
	self.detailTextLabel.frame = frame;
}

@end
