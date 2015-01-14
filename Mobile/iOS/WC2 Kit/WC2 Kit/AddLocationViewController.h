//
//  AddLocationViewController.h
//  PLTSensor
//
//  Created by Davis, Morgan on 3/29/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddLocationViewControllerDelegate;


@interface AddLocationViewController : UIViewController

- (IBAction)doneButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

@property(nonatomic,assign) id <AddLocationViewControllerDelegate>  delegate;
@property(nonatomic,strong) IBOutlet UITableView                    *tableView;
@property(nonatomic,strong) IBOutlet UIBarButtonItem                *doneButton;
@end


@protocol AddLocationViewControllerDelegate <NSObject>

- (void)addLocationViewController:(AddLocationViewController *)theController didAddLocation:(NSDictionary *)location;
- (void)addLocationViewControllerDidCancel:(AddLocationViewController *)theController;

@end
