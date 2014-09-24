//
//  ConfigTempViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/20/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ConfigTempViewController.h"
#import "AppDelegate.h"
#import "PLTDeviceHandler.h"


@interface ConfigTempViewController ()

- (void)updateUI;

@end


@implementation ConfigTempViewController

#pragma mark - IBActions

//- (IBAction)doneButton:(id)sender
//{
//    [self.calTextField resignFirstResponder];
//    float temp_c = self.calTextField.text.floatValue;
//    if (!self.celciusMetric) {
//        temp_c = (self.calTextField.text.floatValue - 32.0) * (5.0/9.0);
//    }
//    self.ambientTempCelcius = temp_c;
//    
//    [self.delegate configTempViewController:self didAcceptMetric:self.celciusMetric ambientTemp:self.ambientTempCelcius];
//}
//
//- (IBAction)cancelButton:(id)sender
//{
//    [self.delegate configTempViewControllerDidCancel:self];
//}


- (IBAction)metricChanged:(UISegmentedControl *)sender
{
    self.celciusMetric = !sender.selectedSegmentIndex;
    [self updateUI];
}

#pragma mark - Private

- (void)updateUI
{
    float tempValue = self.ambientTempCelcius;
    if (!self.celciusMetric) {
        tempValue = ((float)self.ambientTempCelcius)*9.0/5.0+32.0;
    }
    self.calTextField.text = [NSString stringWithFormat:@"%ld",lroundf(tempValue)];
    self.calMetricLabel.text = ( self.celciusMetric ? @"°C" : @"°F" );
}

//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    float temp_c = textField.text.floatValue;
//    if (!self.celciusMetric) {
//        temp_c = (textField.text.floatValue - 32.0) * (5.0/9.0);
//    }
//    self.ambientTempCelcius = temp_c;
//    
//    return YES;
//}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ConfigTempViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Temp Settings";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	//controller.celciusMetric = self.celciusMetric;
	self.celciusMetric = [DEFAULTS boolForKey:PLTDefaultsKeyMetricUnits];
    //if (self.celciusOffset != FLT_MIN) controller.ambientTempCelcius = self.temp + self.celciusOffset;
	float temp = [[[PLTDeviceHandler sharedManager] latestInfo][PLTHeadsetInfoKeyTemperature] floatValue];
	float offset = [DEFAULTS boolForKey:PLTDefaultsKeyTemperatureOffsetCelcius];
	if (offset>.00001) self.ambientTempCelcius = temp + offset;
    else self.ambientTempCelcius = temp;
    
    self.metricSegmentedControl.selectedSegmentIndex = !self.celciusMetric;
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[DEFAULTS setBool:self.celciusMetric forKey:PLTDefaultsKeyMetricUnits];
	[DEFAULTS setFloat:self.ambientTempCelcius - [[[PLTDeviceHandler sharedManager] latestInfo][PLTHeadsetInfoKeyTemperature] floatValue]
				forKey:PLTDefaultsKeyTemperatureOffsetCelcius];
}

@end
