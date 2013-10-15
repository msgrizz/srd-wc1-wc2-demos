//
//  ImageSelectViewController.m
//  HT-CMX
//
//  Created by Davis, Morgan on 10/14/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ImageSelectViewController.h"
#import "AppDelegate.h"


@interface ImageSelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) NSArray *images;

@end


@implementation ImageSelectViewController


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageCell"];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
	}
	
	NSString *label = self.images[indexPath.row];
	cell.textLabel.text = label;
	if ([label isEqualToString:[DEFAULTS objectForKey:PLTDefaultsKeyImage]]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *imageName = self.images[indexPath.row];
	[self.delegate imageSelectViewController:self didSelectImage:imageName];
	[self.tableView reloadData];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ImageSelectViewController" bundle:nibBundleOrNil];
    if (self) {
        self.images = @[@"Frozen Food", @"Deodorant"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"Image";
	self.navigationItem.hidesBackButton = NO;
}

@end
