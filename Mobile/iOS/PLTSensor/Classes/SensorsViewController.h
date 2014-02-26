//
//  SensorsViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/15/13.
//  Copyright (c) 2013 Cambridge Silicon Radio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CC3GLMatrix.h"


@interface SensorsViewController : UITableViewController

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

@end


@interface ExtendedLabelWidthTableViewCell : UITableViewCell
@end
