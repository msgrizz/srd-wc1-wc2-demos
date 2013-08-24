//
//  SelectionListViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/27/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SelectionListViewController.h"


@interface SelectionListViewController ()

@end


@implementation SelectionListViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlainCell"];
    }
    
    cell.textLabel.text = self.listItems[indexPath.row][@"label"];
	
	
	if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //cell.textLabel.textColor = [UIColor colorWithRed:(81.0/256.0) green:(102.0/256.0) blue:(145.0/256.0) alpha:1.0];
        //cell.textLabel.textColor = [UIColor colorWithRed:(44.0/256.0) green:(93.0/256.0) blue:(205.0/256.0) alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:(56.0/256.0) green:(84.0/256.0) blue:(135.0/256.0) alpha:1.0];
    }
	else if (![self.listItems[indexPath.row][@"enabled"] boolValue]) {
		cell.textLabel.textColor = [UIColor grayColor];
	}
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.listItems[indexPath.row][@"enabled"] boolValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger previousSelection = self.selectedIndex;
    self.selectedIndex = indexPath.row;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:previousSelection inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.delegate selectionListViewController:self didSelectItemWithLabel:self.listItems[indexPath.row][@"label"]
                                       context:self.listItems[indexPath.row][@"context"]
                                                              index:indexPath.row];
    //[self.delegate selectionListViewController:self didSelectItem:self.listItems[indexPath.row] atIndex:indexPath.row];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"SelectionListViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	CGSize contentSize = [self contentSizeForViewInPopover];
	contentSize.height = 789.0;
	self.contentSizeForViewInPopover = contentSize;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.contentSizeForViewInPopover = self.navigationController.contentSizeForViewInPopover;
}

@end
