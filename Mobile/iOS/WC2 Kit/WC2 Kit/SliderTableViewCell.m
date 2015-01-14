//
//  SliderTableViewCell.m
//  PLTSensor
//
//  Created by Morgan Davis on 12/29/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import "SliderTableViewCell.h"


@interface SliderTableViewCell () {
	float	_minValue;
	float	_maxValue;
	float	_value;
	id		_target;
	SEL		_action;
}

@property(nonatomic,strong) UISlider *sliderControl;

@end


@implementation SliderTableViewCell

@dynamic value;
@dynamic target;
@dynamic action;

- (float)minValue
{
	return _minValue;
}

- (void)setMinValue:(float)aValue
{
	_minValue = aValue;
	self.sliderControl.minimumValue = _minValue;
}

- (float)maxValue
{
	return _maxValue;
}

- (void)setMaxValue:(float)aValue
{
	_maxValue = aValue;
	self.sliderControl.maximumValue = _maxValue;
}

- (float)value
{
	return _value;
}

- (void)setValue:(float)aValue
{
	_value = aValue;
	self.sliderControl.value = _value;
}

- (id)target
{
	return _target;
}

- (void)setTarget:(id)target
{
	[self.sliderControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
	_target = target;
	[self.sliderControl addTarget:_target action:_action forControlEvents:UIControlEventValueChanged];
}

- (SEL)action
{
	return _action;
}

- (void)setAction:(SEL)action
{
	[self.sliderControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
	_action = action;
	[self.sliderControl addTarget:_target action:_action forControlEvents:UIControlEventValueChanged];
}

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.sliderControl = [[UISlider alloc] initWithFrame:CGRectZero];
		self.accessoryView = self.sliderControl;
		[self.sliderControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return self;
}

@end
