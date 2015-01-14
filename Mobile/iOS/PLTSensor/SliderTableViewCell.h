//
//  SliderTableViewCell.h
//  CSR Wireless Sensor
//
//  Created by Morgan Davis on 12/29/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SliderTableViewCell : UITableViewCell

@property(nonatomic,assign) float	value;
@property(nonatomic,assign) float	minValue;
@property(nonatomic,assign) float	maxValue;
@property(nonatomic,strong) id		target;
@property(nonatomic,assign) SEL		action;

@end
