//
//  ServerStatusViewController.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/2/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerStatusViewControllerDelegate;


@interface ServerStatusViewController : UITableViewController

@property(nonatomic,assign) id <ServerStatusViewControllerDelegate>     delegate;

@end


@protocol ServerStatusViewControllerDelegate <NSObject>

- (void)serverStatusViewController:(ServerStatusViewController *)theController didRegister:(BOOL)flag;
- (void)serverStatusViewControllerDidDisconnect:(ServerStatusViewController *)theController;

@end

