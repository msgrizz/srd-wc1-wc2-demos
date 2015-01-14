//
//  UITableView+Cells.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/2/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "UITableView+Cells.h"
#import "SwitchTableViewCell.h"
#import "SliderTableViewCell.h"
#import "SegmentedControlCell.h"


@implementation UITableView (Cells)

- (UITableViewCell *)defaultCell
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"DefaultCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
    }
    return cell;
}

- (UITableViewCell *)value1Cell
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"Value1Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1Cell"];
    }
    return cell;
}

- (UITableViewCell *)value2Cell
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"Value2Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Value2Cell"];
    }
    return cell;
}

- (UITableViewCell *)subtitleCell
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"SubtitleCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SubtitleCell"];
    }
    return cell;
}

- (UITableViewCell *)buttonCell
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"ButtonCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    return cell;
}

- (SwitchTableViewCell *)switchCell
{
    SwitchTableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"SwitchCell"];
    if (!cell) {
        cell = [[SwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.target = self;
        cell.on = NO;
    }
    return cell;
}

- (SliderTableViewCell *)sliderCell
{
	// Morgan 141229: This doesn't work right.
	SliderTableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"SliderCell"];
	if (!cell) {
		cell = [[SliderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SliderCell"];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.target = self;
	}
	return cell;
}

//- (SwitchTableViewCell *)switchCellValue2
//{
//    SwitchTableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"SwitchCellValue2"];
//    if (!cell) {
//        cell = [[SwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"SwitchCellValue2"];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.target = self;
//        cell.on = NO;
//    }
//    return cell;
//}

- (UITableViewCell *)textFieldCell
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextFieldCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 190, 39)];
        textField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        textField.borderStyle = UITextBorderStyleNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autoresizesSubviews = YES;
        //textField.delegate = self;
        cell.accessoryView = textField;
    }
    return cell;
}

- (UITableViewCell *)segmentedControlCellWithItems:(NSArray *)items
{
//	UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"SegmentedCell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegmentedCell"];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.textLabel.textAlignment = UITextAlignmentLeft;
//		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"°C", @"°F"]];
//		
//    }
//    return cell;

    SegmentedControlCell *cell = [self dequeueReusableCellWithIdentifier:@"SegmentedControlCell"];
    if (!cell) {
        cell = [[SegmentedControlCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegmentedControlCell" items:items];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.target = self;
        cell.on = NO;
    }
    return cell;
}

@end
