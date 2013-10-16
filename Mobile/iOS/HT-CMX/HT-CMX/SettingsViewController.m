//
//  SettingsViewController.m
//  HT-CMX
//
//  Created by Davis, Morgan on 10/14/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ImageSelectViewController.h"


typedef NS_ENUM(NSUInteger, PLTTableViewRow) {
	PLTTableViewRowSensitivity,
	PLTTableViewRowSmoothing,
    PLTTableViewRowImage,
	PLTTableViewRowScale,
	PLTTableViewRowHeatMap
};


@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, ImageSelectViewControllerDelegate>

@property(nonatomic, retain)	IBOutlet UITableViewCell	*sensitivityTableViewItem;
@property(nonatomic, strong)	IBOutlet UISlider			*sensitivitySlider;
@property(nonatomic, retain)	IBOutlet UITableViewCell	*scaleTableViewItem;
@property(nonatomic, strong)	IBOutlet UISlider			*scaleSlider;
@property(nonatomic, retain)	IBOutlet UITableViewCell	*smoothingTableViewItem;
@property(nonatomic, strong)	IBOutlet UISwitch			*smoothingSwitch;
@property(nonatomic, retain)	IBOutlet UITableViewCell	*heatMapTableViewItem;
@property(nonatomic, strong)	IBOutlet UISwitch			*heatMapSwitch;

- (IBAction)sensitivitySlider:(UISlider *)sender;
- (IBAction)scaleSlider:(UISlider *)sender;
- (IBAction)smoothingSwitch:(UISwitch *)sender;
- (IBAction)heatMapSwitch:(UISwitch *)sender;
- (void)doneButton:(id)sender;

@end


@implementation SettingsViewController
	
#pragma mark - Private

- (IBAction)sensitivitySlider:(UISlider *)sender
{
	[DEFAULTS setFloat:sender.value forKey:PLTDefaultsKeySensitivity];
	[self.delegate settingsViewControllerDidChangeValue:self];
}

- (IBAction)scaleSlider:(UISlider *)sender
{
	[DEFAULTS setFloat:sender.value forKey:PLTDefaultsKeyScale];
	[self.delegate settingsViewControllerDidChangeValue:self];
}

- (IBAction)smoothingSwitch:(UISwitch *)sender
{
	[DEFAULTS setFloat:sender.on forKey:PLTDefaultsKeySmoothing];
	//[self.delegate settingsViewControllerDidChangeValue:self];
}

- (IBAction)heatMapSwitch:(UISwitch *)sender
{
	[DEFAULTS setFloat:sender.on forKey:PLTDefaultsKeyHeatMap];
	//[self.delegate settingsViewControllerDidChangeValue:self];
}

- (void)doneButton:(id)sender
{
	[self.delegate settingsViewControllerDidEnd:self];
}
	
#pragma mark - UITableViewDataSource
	
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	switch (indexPath.row) {
		case PLTTableViewRowSensitivity:
			cell = self.sensitivityTableViewItem;
			self.sensitivitySlider.value = [DEFAULTS floatForKey:PLTDefaultsKeySensitivity];
			break;
		case PLTTableViewRowSmoothing:
			cell = self.smoothingTableViewItem;
			self.smoothingSwitch.on = [DEFAULTS boolForKey:PLTDefaultsKeySmoothing];
			break;
		case PLTTableViewRowScale:
			cell = self.scaleTableViewItem;
			self.scaleSlider.value = [DEFAULTS floatForKey:PLTDefaultsKeyScale];
			break;
		case PLTTableViewRowImage: {
			cell = [tableView dequeueReusableCellWithIdentifier:@"ImagesCell"];
			if (!cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ImagesCell"];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.textAlignment = NSTextAlignmentLeft;
				cell.textLabel.text = @"Image";
			}
			cell.detailTextLabel.text = [DEFAULTS objectForKey:PLTDefaultsKeyImage];
			break; }
		case PLTTableViewRowHeatMap:
			cell = self.heatMapTableViewItem;
			self.heatMapSwitch.on = [DEFAULTS boolForKey:PLTDefaultsKeyHeatMap];
			break;
	}
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.row == PLTTableViewRowImage);
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == PLTTableViewRowImage) {
		ImageSelectViewController *viewController = [[ImageSelectViewController alloc] initWithNibName:nil bundle:nil];
		viewController.delegate = self;
		[self.navigationController pushViewController:viewController animated:YES];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ImageViewControllerDelegate

- (void)imageSelectViewController:(ImageSelectViewController *)controller didSelectImage:(NSString *)image
{
	[DEFAULTS setObject:image forKey:PLTDefaultsKeyImage];
	[self.delegate settingsViewControllerDidChangeValue:self];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"SettingsViewController" bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton:)];
	self.navigationItem.title = @"Settings";
	self.navigationItem.leftBarButtonItem = doneItem;
}
	
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
	[self.delegate settingsViewControllerDidChangeValue:self];
}

@end
