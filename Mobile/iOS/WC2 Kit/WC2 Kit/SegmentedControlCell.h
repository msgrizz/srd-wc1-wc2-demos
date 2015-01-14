//
//  SegmentedControlCell.h
//  PLTSensor
//
//  Created by Davis, Morgan on 4/8/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SegmentedControlCell : UITableViewCell

@property(nonatomic,assign) BOOL    on;
@property(nonatomic,strong) id      target;
@property(nonatomic,assign) SEL     action;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier items:(NSArray *)items;

@end
