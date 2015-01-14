//
//  SegmentedControlCell.m
//  PLTSensor
//
//  Created by Davis, Morgan on 4/8/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SegmentedControlCell.h"


@interface SegmentedControlCell () {

	id          _target;
	SEL         _action;
}

@property(nonatomic,strong) UISegmentedControl *segmentedControl;

@end


@implementation SegmentedControlCell

@dynamic target;
@dynamic action;

- (id)target
{
    return _target;
}

- (void)setTarget:(id)target
{
    [self.segmentedControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    _target = target;
    [self.segmentedControl addTarget:_target action:_action forControlEvents:UIControlEventValueChanged];
}

- (SEL)action
{
    return _action;
}

- (void)setAction:(SEL)action
{
    [self.segmentedControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    _action = action;
    [self.segmentedControl addTarget:_target action:_action forControlEvents:UIControlEventValueChanged];
}

//#pragma mark - Private
//
//- (void)segmentedControlChanged:(id)sender
//{
//	[self.target performSelector:nil];
//}

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier items:(NSArray *)items
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        self.accessoryView = self.segmentedControl;
        //[self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

@end
