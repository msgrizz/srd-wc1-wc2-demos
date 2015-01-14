//
//  SwitchTableViewCell.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SwitchTableViewCell : UITableViewCell

@property(nonatomic,assign) BOOL    on;
@property(nonatomic,strong) id      target;
@property(nonatomic,assign) SEL     action;

@end
