//
//  SettingsViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const PLTSettingsPopoverDidDismissNotification;

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UITableViewController

//- (CGSize)realPopoverSize:(BOOL)reload;
- (IBAction)doneButton:(id)sender;

@property(nonatomic,assign) id <SettingsViewControllerDelegate>     delegate;
@property(nonatomic,strong) IBOutlet UITableViewCell                *connectionStatusCell;
@property(nonatomic,strong) IBOutlet UILabel                        *connectionStatusLabel;
@property(nonatomic,strong) IBOutlet UILabel                        *connectionUsernameLabel;
@property(nonatomic,strong) IBOutlet UILabel                        *connectionTimeLabel;

@end


@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidEnd:(SettingsViewController *)theController;
//- (void)settingsViewControllerDidClickStreetViewPrecache:(SettingsViewController *)theController;
- (UIPopoverController *)popoverControllerForSettingsViewController:(SettingsViewController *)theController;

@end
