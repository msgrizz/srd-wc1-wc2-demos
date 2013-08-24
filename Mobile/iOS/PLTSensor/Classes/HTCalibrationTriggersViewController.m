//
//  HTCalibrationTriggersViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 7/16/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "HTCalibrationTriggersViewController.h"
#import "UITableView+Cells.h"
#import "AppDelegate.h"
#import "PLTHeadsetManager.h"


#define DEVICE_IPAD		([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


typedef NS_ENUM(NSUInteger, HTCalibrationTriggersTableRow) {
    HTCalibrationTriggersTableRowShake,
    HTCalibrationTriggersTableRowDon
};


@interface HTCalibrationTriggersViewController ()

@end


@implementation HTCalibrationTriggersViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView defaultCell];
	NSUInteger triggers = [(NSNumber *)[DEFAULTS objectForKey:PLTDefaultsKeyHeadTrackingCalibrationTriggers] unsignedIntegerValue];
    
    switch (indexPath.row) {
            
        case HTCalibrationTriggersTableRowShake:
			
			if (DEVICE_IPAD) cell.textLabel.text = @"Shake iPad";
			else cell.textLabel.text = @"Shake iPhone";
			
			if (triggers & PLTHeadTrackingCalibrationTriggerShake) cell.accessoryType = UITableViewCellAccessoryCheckmark;
			else cell.accessoryType = UITableViewCellAccessoryNone;
			
            break;
            
        case HTCalibrationTriggersTableRowDon:
				
			cell.textLabel.text = @"Don Headset";
			
			if (triggers & PLTHeadTrackingCalibrationTriggerDon) cell.accessoryType = UITableViewCellAccessoryCheckmark;
			else cell.accessoryType = UITableViewCellAccessoryNone;
			
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) cell.accessoryType = UITableViewCellAccessoryNone;
	else cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSUInteger triggers = [(NSNumber *)[DEFAULTS objectForKey:PLTDefaultsKeyHeadTrackingCalibrationTriggers] unsignedIntegerValue];
	switch (indexPath.row) {
            
        case HTCalibrationTriggersTableRowShake:
			if (cell.accessoryType == UITableViewCellAccessoryCheckmark) triggers |= PLTHeadTrackingCalibrationTriggerShake;
			else triggers &= ~PLTHeadTrackingCalibrationTriggerShake;
            break;
            
        case HTCalibrationTriggersTableRowDon:
			if (cell.accessoryType == UITableViewCellAccessoryCheckmark) triggers |= PLTHeadTrackingCalibrationTriggerDon;
			else triggers &= ~PLTHeadTrackingCalibrationTriggerDon;
            break;
    }
	[DEFAULTS setObject:@(triggers) forKey:PLTDefaultsKeyHeadTrackingCalibrationTriggers];
	[PLTHeadsetManager sharedManager].headTrackingCalibrationTriggers = triggers;
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"HTCalibrationTriggersViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"HT Calibration Triggers";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

@end
