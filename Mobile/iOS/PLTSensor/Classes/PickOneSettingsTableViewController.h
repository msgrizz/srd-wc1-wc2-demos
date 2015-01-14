//
//  PickOneSettingsTableViewController.h
//  CSR Wireless Sensor
//
//  Created by Morgan Davis on 12/29/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>




/*********************************************************************************
 
	Nevermind. Looks like we already did this: SelectionListViewController
 
 *********************************************************************************/



@protocol PickOneSettingsTableViewControllerDelegate;


@interface PickOneSettingsTableViewController : UITableViewController

- (id)initWithTitle:(NSString *)title choices:(NSArray *)choices delegate:(id<PickOneSettingsTableViewControllerDelegate>)delegate;

@end


@protocol PickOneSettingsTableViewControllerDelegate <NSObject>

- (void)PickOneSettingsTableViewController:(PickOneSettingsTableViewController *)aController didPickIndex:(NSInteger)index;
- (void)PickOneSettingsTableViewControllerDidAbort:(PickOneSettingsTableViewController *)aController;

@end
