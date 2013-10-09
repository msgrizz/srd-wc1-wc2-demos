//
//  StreetViewViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/21/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreetViewViewController : UIViewController

- (void)precache;

@property(nonatomic,strong)     IBOutlet UIImageView        *imageView;
//@property(nonatomic,strong)     IBOutlet UINavigationBar    *navBar;
@property(nonatomic,strong)     IBOutlet UILabel            *geolocationLabel;
@property(nonatomic,strong)     IBOutlet UILabel            *messageRateLabel;
@property(nonatomic,strong)     IBOutlet UILabel            *frameRateLabel;
//@property(nonatomic,strong)     IBOutlet UIView             *precachingView;
@property(nonatomic,strong)     IBOutlet UILabel			*precachingLabel;
@property(nonatomic,strong)     IBOutlet UIProgressView     *precachingProgressBar;

@end
