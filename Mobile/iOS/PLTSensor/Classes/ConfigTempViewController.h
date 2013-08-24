//
//  ConfigTempViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/20/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfigTempViewControllerDelegate;


@interface ConfigTempViewController : UIViewController

//- (IBAction)doneButton:(id)sender;
//- (IBAction)cancelButton:(id)sender;
- (IBAction)metricChanged:(id)sender;

@property(nonatomic,assign) id <ConfigTempViewControllerDelegate>   delegate;
@property(nonatomic,assign) BOOL                                    celciusMetric;
@property(nonatomic,assign) float                                   ambientTempCelcius;
@property(nonatomic,strong) IBOutlet UISegmentedControl             *metricSegmentedControl;
@property(nonatomic,strong) IBOutlet UITextField                    *calTextField;
@property(nonatomic,strong) IBOutlet UILabel                        *calMetricLabel;

@end


@protocol ConfigTempViewControllerDelegate <NSObject>

- (void)configTempViewController:(ConfigTempViewController *)controller didAcceptMetric:(BOOL)celcius ambientTemp:(float)ambientTempCelcius;
- (void)configTempViewControllerDidCancel:(ConfigTempViewController *)controller;

@end
