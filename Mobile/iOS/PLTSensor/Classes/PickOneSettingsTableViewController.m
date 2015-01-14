//
//  PickOneSettingsTableViewController.m
//  CSR Wireless Sensor
//
//  Created by Morgan Davis on 12/29/14.
//  Copyright (c) 2014 Plantronics, Inc. All rights reserved.
//

#import "PickOneSettingsTableViewController.h"


@interface PickOneSettingsTableViewController ()

@property(nonatomic,retain) NSString										*title;
@property(nonatomic,retain) NSArray											*choices;
@property(nonatomic,retain) id<PickOneSettingsTableViewControllerDelegate>	delegate;

@end


@implementation PickOneSettingsTableViewController

#pragma mark - Public

- (id)initWithTitle:(NSString *)title choices:(NSArray *)choices delegate:(id<PickOneSettingsTableViewControllerDelegate>)delegate
{
	self = [super init];
	self.choices = choices;
	return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.choices count];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

#pragma mark - UITableView

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

@end
