//
//  SensorsViewController.m
//  BangleTD&S
//
//  Created by Morgan Davis on 6/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "SensorsViewController.h"
#import "PLTDevice.h"
#import "PLTDevice_Bangle.h"
#import "PLTDevice_Internal.h"
#import "UITableView+Cells.h"
#import "AppDelegate.h"
#import "PLTAmbientHumidityInfo.h"
#import "PLTAmbientPressureInfo.h"
#import "PLTSkinTemperatureInfo.h"


typedef enum {
	PLTSensorsTableRowAmbientHumidity = 0,
	PLTSensorsTableRowAmbientPressure,
	PLTSensorsTableRowSkinTemp,
	PLTSensorsTableRowHeartRate,
	PLTSensorsTableRowSkinConductivity,
	PLTSensorsTableRowAmbientLight,
	PLTSensorsTableRowAmbientTemperature
} PLTSensorsTableRow;


@interface SensorsViewController () <UITableViewDataSource, UITableViewDelegate, PLTDeviceSubscriber>

@property(nonatomic,strong)	IBOutlet	UITableView		*tableView;
@property(nonatomic,strong)	PLTDevice					*device;

//@property(nonatomic,strong) IBOutlet UITableViewCell    *orientationTableViewCell;
//@property(nonatomic,strong) IBOutlet UIProgressView     *headingProgressView;
//@property(nonatomic,strong) IBOutlet UIProgressView     *rollProgressView;
//@property(nonatomic,strong) IBOutlet UIProgressView     *pitchProgressView;
//@property(nonatomic,strong) IBOutlet UILabel            *headingValueLabel;
//@property(nonatomic,strong) IBOutlet UILabel            *rollValueLabel;
//@property(nonatomic,strong) IBOutlet UILabel            *pitchValueLabel;

@end


@implementation SensorsViewController

#pragma mark - Private

//- (void)subscribeToInfo
//{
//	NSLog(@"subscribeToInfo");
//	
//	NSError *err = [self.device subscribe:self	toService:(PLTService)PLTServiceAmbientHumidity			withMode:PLTSubscriptionModePeriodic	andPeriod:100];
//	if (err) NSLog(@"Error: %@", err);
//	err = [self.device subscribe:self			toService:(PLTService)PLTServiceAmbientPressure			withMode:PLTSubscriptionModePeriodic	andPeriod:100];
//	if (err) NSLog(@"Error: %@", err);
//	err = [self.device subscribe:self			toService:(PLTService)PLTServiceSkinTemperature			withMode:PLTSubscriptionModePeriodic	andPeriod:100];
//	if (err) NSLog(@"Error: %@", err);
////	NSError *err = [self.device subscribe:self			toService:(PLTService)PLTServiceOrientationTracking		withMode:PLTSubscriptionModePeriodic	andPeriod:50];
////	if (err) NSLog(@"Error: %@", err);
//}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	cell = [tableView dequeueReusableCellWithIdentifier:@"plain_auxcell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain_auxcell"];
	}
	
	
	cell.textLabel.font = [UIFont systemFontOfSize:18];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
	cell.backgroundColor = [UIColor colorWithWhite:.95 alpha:1.0];
	
	switch (indexPath.row) {
		case PLTSensorsTableRowAmbientHumidity: {
			cell.textLabel.text = @"humidity";
			static float lastValue = 0;
			PLTAmbientHumidityInfo *info = (PLTAmbientHumidityInfo *)[self.device cachedInfoForService:(PLTService)PLTServiceAmbientHumidity];
			float value = lastValue;
			if (info.humidity < 70 && info.humidity > 20) {
				value = info.humidity;
				lastValue = value;
			}
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f %%", value];
			break; }
		case PLTSensorsTableRowAmbientPressure: {
			cell.textLabel.text = @"pressure";
			PLTAmbientPressureInfo *info = (PLTAmbientPressureInfo *)[self.device cachedInfoForService:(PLTService)PLTServiceAmbientPressure];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f µb", info.pressure];
			break; }
		case PLTSensorsTableRowSkinTemp: {
			cell.textLabel.text = @"skin temp";
			PLTSkinTemperatureInfo *info = (PLTSkinTemperatureInfo *)[self.device cachedInfoForService:(PLTService)PLTServiceSkinTemperature];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f °F", PLTFahrenheitFromCelsius(info.temperature)];
			break; }
		case PLTSensorsTableRowHeartRate: {
			cell.textLabel.text = @"heart rate";
			cell.detailTextLabel.text = @"x bpm";
			break; }
		case PLTSensorsTableRowSkinConductivity: {
			cell.textLabel.text = @"skn moisture";
			//[cell.textLabel sizeToFit];
			cell.textLabel.minimumScaleFactor = .2;
			cell.detailTextLabel.text = @"x %";
			break; }
		case PLTSensorsTableRowAmbientLight: {
			cell.textLabel.text = @"light";
			cell.detailTextLabel.text = @"x lm";
			break; }
		case PLTSensorsTableRowAmbientTemperature: {
			cell.textLabel.text = @"temp";
			cell.detailTextLabel.text = @"x °F";
			break; }
//		case PLTSensorsTableRowOrientation: {
//			cell = [tableView dequeueReusableCellWithIdentifier:@"orientation"];
//			UIProgressView *headingProgressView = (UIProgressView *)[cell viewWithTag:1];
//			UIProgressView *pitchProgressView = (UIProgressView *)[cell viewWithTag:2];
//			UIProgressView *rollProgressView = (UIProgressView *)[cell viewWithTag:3];
//			UILabel *headingValueLabel = (UILabel *)[cell viewWithTag:101];
//			UILabel *pitchValueLabel = (UILabel *)[cell viewWithTag:102];
//			UILabel *rollValueLabel = (UILabel *)[cell viewWithTag:103];
//			PLTOrientationTrackingInfo *info = (PLTOrientationTrackingInfo *)[self.device cachedInfoForService:(PLTService)PLTServiceOrientationTracking];
//			PLTEulerAngles angles = info.eulerAngles;
//			headingValueLabel.text = [NSString stringWithFormat:@"%ld°", lroundf(angles.x)];
//			pitchValueLabel.text = [NSString stringWithFormat:@"%ld°", lroundf(angles.y)];
//			rollValueLabel.text = [NSString stringWithFormat:@"%ld°", lroundf(angles.z)];
//			break; }
		default:
			break;
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"SensorsViewController:PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	[self.tableView reloadData];
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}
            
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.tableView setContentInset:UIEdgeInsetsMake(20 + 44,0,0,0)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	self.device = appDelegate.device;
	//[self subscribeToInfo];
	
	[self.device sneakySneaky:self];
}

@end
