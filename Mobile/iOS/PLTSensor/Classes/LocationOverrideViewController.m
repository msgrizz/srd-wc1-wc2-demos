//
//  LocationOverrideViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/29/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "LocationOverrideViewController.h"
#import "AppDelegate.h"
#import "AddLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UITableView+Cells.h"
#import "LocationMonitor.h"


NSString *const LocationOverrideDidSelectNewLocation =  @"LocationOverrideDidSelectNewLocation";


@interface LocationOverrideViewController () <AddLocationViewControllerDelegate>

- (void)editButton:(id)sender;
- (void)doneButton:(id)sender;
- (void)cancelButton:(id)sender;
- (void)showEditButton;
- (void)showDoneAndCancelButtons;
- (void)editButton:(id)sender;
- (void)selectCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)saveToDefaults;

@property(nonatomic,strong) NSIndexPath         *selectedIndexPath;
@property(nonatomic,strong) NSMutableArray      *editingLocations;
@property(nonatomic,strong) NSString            *editingLocationSelection;
@property(nonatomic,assign) BOOL                addingLocation;
@property(nonatomic,assign) NSInteger           numAddedLocations;

@end


@implementation LocationOverrideViewController

#pragma mark - Private

- (void)editButton:(id)sender
{
    self.numAddedLocations = 0;
    
    NSArray *deleteRows = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    NSArray *insertRows = @[[NSIndexPath indexPathForRow:[self.editingLocations count]-1 inSection:0]];
    NSMutableArray *reloadeRows = [@[[NSIndexPath indexPathForRow:[self.editingLocations count] inSection:0]] mutableCopy];
    if (!([deleteRows containsObject:self.selectedIndexPath] || [reloadeRows containsObject:self.selectedIndexPath]) ) {
        [reloadeRows addObject:self.selectedIndexPath];
    }
    
    [self.tableView setEditing:YES animated:YES];

    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadRowsAtIndexPaths:reloadeRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self showDoneAndCancelButtons];
}

- (void)doneButton:(id)sender
{
    NSArray *deleteRows = @[[NSIndexPath indexPathForRow:[self.editingLocations count] inSection:0]];
    NSArray *insertRows = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    NSIndexPath *selectionIndex = [NSIndexPath indexPathForRow:self.selectedIndexPath.row-1 inSection:self.selectedIndexPath.section];
    NSMutableArray *reloadeRows = [@[] mutableCopy];
    if (!([deleteRows containsObject:selectionIndex] || [reloadeRows containsObject:selectionIndex]) ) {
        [reloadeRows addObject:selectionIndex];
    }
    
    [self.tableView setEditing:NO animated:YES];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadRowsAtIndexPaths:reloadeRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self showEditButton];
    self.addingLocation = NO;
    [self saveToDefaults];
}

- (void)cancelButton:(id)sender
{
    NSMutableArray *deleteRows = [@[[NSIndexPath indexPathForRow:[self.editingLocations count] inSection:0]] mutableCopy];
    for (NSInteger i = 0; i<self.numAddedLocations ; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.editingLocations count] - 1 - i inSection:0];
        [deleteRows addObject:path];
        [self.editingLocations removeObjectAtIndex:[self.editingLocations count]-1];
    }
    NSArray *insertRows = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    NSIndexPath *selectionIndex = [NSIndexPath indexPathForRow:self.selectedIndexPath.row - 1 inSection:self.selectedIndexPath.section];
    NSMutableArray *reloadeRows = [@[] mutableCopy];
    if (!([deleteRows containsObject:selectionIndex] || [reloadeRows containsObject:selectionIndex]) ) {
        [reloadeRows addObject:selectionIndex];
    }
    
    [self.tableView setEditing:NO animated:YES];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadRowsAtIndexPaths:reloadeRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    self.numAddedLocations = 0;
    
    [self showEditButton];
}

- (void)selectCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor colorWithRed:(56.0/256.0) green:(84.0/256.0) blue:(135.0/256.0) alpha:1.0];
    self.selectedIndexPath = indexPath;
}

- (void)showEditButton
{
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                       target:self action:@selector(editButton:)];
    self.navigationItem.rightBarButtonItem = editBarButtonItem;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)showDoneAndCancelButtons
{
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self action:@selector(doneButton:)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
}

- (void)loadFromDefaults
{
    self.editingLocations = [[DEFAULTS objectForKey:PLTDefaultsKeyOverrideLocations] mutableCopy];
    self.editingLocationSelection = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
}

- (void)saveToDefaults
{
    [DEFAULTS setObject:self.editingLocations forKey:PLTDefaultsKeyOverrideLocations];
    [DEFAULTS setObject:self.editingLocationSelection forKey:PLTDefaultsKeyOverrideSelectedLocation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + [self.editingLocations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlainCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor blackColor];
    
    NSString *selectedLabel = self.editingLocationSelection;
    
    if (!tableView.isEditing && indexPath.row == 0) {
        cell.textLabel.text = @"None";
        //cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:0];
        if (!tableView.isEditing && [selectedLabel isEqualToString:@"__none"]) {
            [self selectCell:cell indexPath:indexPath];
        }
    }
    else if (tableView.isEditing && (indexPath.row == [tableView numberOfRowsInSection:0]-1)) {
        cell.textLabel.text = @"add new location";
        cell.textLabel.textColor = [UIColor colorWithRed:(56.0/256.0) green:(84.0/256.0) blue:(135.0/256.0) alpha:1.0];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    }
    else {
        cell = [tableView subtitleCell];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        NSInteger editingOffset = (tableView.editing ? 0 : -1);
        NSInteger index = indexPath.row+editingOffset;
        NSDictionary *location = ((NSDictionary *)self.editingLocations[index]);
        NSString *label = location[PLTDefaultsKeyOverrideLocationLabel];
        CLLocationDegrees lat = [((NSNumber *)location[PLTDefaultsKeyOverrideLocationLatitude]) doubleValue];
        CLLocationDegrees lng = [((NSNumber *)location[PLTDefaultsKeyOverrideLocationLongitude]) doubleValue];
        cell.textLabel.text = label;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", lat, lng];
        if (!tableView.isEditing && [selectedLabel isEqualToString:label]) {
            [self selectCell:cell indexPath:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *location = self.editingLocations[indexPath.row];
        if ([self.editingLocationSelection isEqualToString:(NSString *)location[PLTDefaultsKeyOverrideLocationLabel]]) {
            self.editingLocationSelection = @"__none";
        }
        
        [self.editingLocations removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing && (indexPath.row != [tableView numberOfRowsInSection:0]-1)) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.isEditing) {
        AddLocationViewController *controller = [[AddLocationViewController alloc] initWithNibName:nil bundle:nil];
        controller.delegate = self;
        self.addingLocation = YES;
        //[self presentModalViewController:controller animated:YES];
		[self.navigationController pushViewController:controller animated:YES];
    }
    else {
        NSString *selectedLabel;
        if (indexPath.row > 0) selectedLabel = ((NSDictionary *)self.editingLocations[indexPath.row-1])[PLTDefaultsKeyOverrideLocationLabel];
        else selectedLabel = @"__none";
        self.editingLocationSelection = selectedLabel;
        
        NSIndexPath *previousSelection = self.selectedIndexPath;
        self.selectedIndexPath = indexPath;
        [self.tableView reloadRowsAtIndexPaths:@[previousSelection] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self saveToDefaults];
		[[LocationMonitor sharedMonitor] updateLocationNow];
        [[NSNotificationCenter defaultCenter] postNotificationName:LocationOverrideDidSelectNewLocation object:nil];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        if (indexPath.row == [tableView numberOfRowsInSection:0]-1) return UITableViewCellEditingStyleInsert;
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return (indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete);
    }
}

#pragma mark - AddLocationViewControllerDelegate

- (void)addLocationViewController:(AddLocationViewController *)theController didAddLocation:(NSDictionary *)location
{
    NSLog(@"addLocationViewController:didAddLocation: %@",location);
    //[self dismissViewControllerAnimated:YES completion:^(void) {
	[self.navigationController popToViewController:self animated:YES];
        [self.editingLocations addObject:location];
        //self.editingLocationSelection = location[PLTDefaultsKeyOverrideLocationLabel];
        self.numAddedLocations = self.numAddedLocations + 1;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    //}];
}

- (void)addLocationViewControllerDidCancel:(AddLocationViewController *)theController
{
    NSLog(@"addLocationViewControllerDidCancel:");
    //[self dismissViewControllerAnimated:YES completion:nil];
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"LocationOverrideViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Location Spoof";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    [self showEditButton];
	CGSize contentSize = [self contentSizeForViewInPopover];
	contentSize.height = 789.0;
	self.contentSizeForViewInPopover = contentSize;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.addingLocation) {
        [self loadFromDefaults];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.addingLocation) {
        [self saveToDefaults];
    }
}

@end
