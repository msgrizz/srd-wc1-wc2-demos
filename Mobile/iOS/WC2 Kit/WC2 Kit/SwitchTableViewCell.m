//
//  SwitchTableViewCell.m
//  PLTSensor
//
//  Created by Davis, Morgan on 3/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SwitchTableViewCell.h"


@interface SwitchTableViewCell () {
    BOOL        _on;
    id          _target;
    SEL         _action;
}

@property(nonatomic,strong) UISwitch *switchControl;

@end


@implementation SwitchTableViewCell

@dynamic on;
@dynamic target;
@dynamic action;

- (BOOL)on
{
    return _on;
}

- (void)setOn:(BOOL)flag
{
    _on = flag;
    self.switchControl.on = flag;
}

- (id)target
{
    return _target;
}

- (void)setTarget:(id)target
{
    [self.switchControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    _target = target;
    [self.switchControl addTarget:_target action:_action forControlEvents:UIControlEventValueChanged];
}

- (SEL)action
{
    return _action;
}

- (void)setAction:(SEL)action
{
    [self.switchControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    _action = action;
    [self.switchControl addTarget:_target action:_action forControlEvents:UIControlEventValueChanged];
}

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.accessoryView = self.switchControl;
        [self.switchControl setOn:NO animated:NO];
        [self.switchControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
