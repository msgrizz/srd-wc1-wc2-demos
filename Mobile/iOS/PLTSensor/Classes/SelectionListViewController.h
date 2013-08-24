//
//  SelectionListViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/27/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectionListViewControllerDelegate;


@interface SelectionListViewController : UITableViewController

@property(nonatomic,assign) id <SelectionListViewControllerDelegate>    delegate;
@property(nonatomic,assign) NSInteger                                   tag;
@property(nonatomic,strong) NSArray                                     *listItems;
@property(nonatomic,assign) NSUInteger                                  selectedIndex;

@end


@protocol SelectionListViewControllerDelegate <NSObject>

- (void)selectionListViewController:(SelectionListViewController *)theController didSelectItemWithLabel:(NSString *)label context:(id)context index:(NSUInteger)index;

@end
