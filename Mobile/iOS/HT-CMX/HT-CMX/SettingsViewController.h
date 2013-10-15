//
//  SettingsViewController.h
//  HT-CMX
//
//  Created by Davis, Morgan on 10/14/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UITableViewController
	
@property(nonatomic, assign) id <SettingsViewControllerDelegate>	delegate;

@end


@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidChangeValue:(SettingsViewController *)theController;
- (void)settingsViewControllerDidEnd:(SettingsViewController *)theController;
	
@end

