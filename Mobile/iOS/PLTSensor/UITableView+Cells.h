//
//  UITableView+Cells.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/2/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchTableViewCell;
@class SliderTableViewCell;


@interface UITableView (Cells)

- (UITableViewCell *)defaultCell;
- (UITableViewCell *)value1Cell;
- (UITableViewCell *)value2Cell;
- (UITableViewCell *)subtitleCell;
- (UITableViewCell *)buttonCell;
- (SwitchTableViewCell *)switchCell;
- (SliderTableViewCell *)sliderCell;
//- (SwitchTableViewCell *)switchCellValue2;
- (UITableViewCell *)textFieldCell;
- (UITableViewCell *)segmentedControlCellWithItems:(NSArray *)items;

@end
