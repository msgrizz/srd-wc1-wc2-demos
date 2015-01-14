//
//  SettingsViewController.m
//  PLTSensor
//
//  Created by Davis, Morgan on 3/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "SwitchTableViewCell.h"
#import "SliderTableViewCell.h"
#import "SelectionListViewController.h"
#import "LocationOverrideViewController.h"
#import "UITableView+Cells.h"
#import "PLTDeviceHelper.h"
#import "HTCalibrationTriggersViewController.h"
#import "TestFlight.h"
#import "KubiViewController.h"
#import "SettingsAboutViewController.h"
#import "SecurityHelper.h"


NSString *const PLTSettingsSecurityEnabledChangedNotification = @"PLTSettingsSecurityEnabledChangedNotification";
NSString *const PLTSettingsSecurityDeviceChangedNotification = @"PLTSettingsSecurityDeviceChangedNotification";
NSString *const PLTSettingsKubiEnabledChangedNotification = @"PLTSettingsKubiEnabledChangedNotification";
NSString *const PLTSettingsKubiDeviceChangedNotification = @"PLTSettingsKubiDeviceChangedNotification";
NSString *const PLTSettingsKubiSettingsChangedNotification = @"PLTSettingsKubiSettingsChangedNotification";


typedef NS_ENUM(NSUInteger, PLTTableViewSection) {
	PLTTableViewSectionGeneral,
    PLTTableViewSectionHead,
	PLTTableViewSectionStreetView,
	PLTTableViewSectionSecurity,
	PLTTableViewSectionKubi
};

typedef NS_ENUM(NSUInteger, PLTTableViewGeneralRow) {
	PLTTableViewGeneralAbout,
	PLTTableViewGeneralRowHTCalibrationTriggers,
	PLTTableViewGeneralRowMetricUnits
};

typedef NS_ENUM(NSUInteger, PLTTableViewHeadOverlaysRow) {
	PLTTableViewHeadOverlaysRowGestureDetection,
	PLTTableViewHeadOverlaysRowMirrorImage
};

typedef NS_ENUM(NSUInteger, PLTTableViewStreetViewRow) {
	PLTTableViewStreetViewRowLocationOverride
};

typedef NS_ENUM(NSUInteger, PLTTableViewSecurityRow) {
	PLTTableViewSecurityRowEnabled,
	PLTTableViewSecurityRowDevice,
	PLTTableViewSecurityRowEnroll
};

typedef NS_ENUM(NSUInteger, PLTTableViewKubiRow) {
	PLTTableViewKubiRowEnabled,
	PLTTableViewKubiRowDevice,
	PLTTableViewKubiRowMode,
	PLTTableViewKubiRowMirror
};

typedef NS_ENUM(NSUInteger, PLTSelectionListViewTag) {
	PLTSelectionListViewTagSecurityDevice,
	PLTSelectionListViewTagKubiDevice,
	PLTSelectionListViewTagKubiMode
};


@interface SettingsViewController () <SelectionListViewControllerDelegate, SecurityHelperEnrollDelegate, UINavigationControllerDelegate>

- (void)metricUnitsSwitch:(UISwitch *)theSwitch;
- (void)gestureRecognitionSwitch:(UISwitch *)theSwitch;
- (void)mirrorImageSwitch:(UISwitch *)theSwitch;
- (void)securityEnabledSwitch:(UISwitch *)theSwitch;
- (void)kubiEnabledSwitch:(UISwitch *)theSwitch;
- (void)kubiMirrorSwitch:(UISwitch *)theSwitch;

//@property(nonatomic,assign) BOOL		displayingOtherView;
@property(nonatomic,retain) UILabel		*enrollCellDetailTextLabel;

@end


@implementation SettingsViewController

#pragma mark - Public

- (IBAction)doneButton:(id)sender
{
	[self.delegate settingsViewControllerDidEnd:self];
}

#pragma mark - Private

- (void)metricUnitsSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyMetricUnits];
}

- (void)gestureRecognitionSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyHeadGestureRecognition];
}

- (void)mirrorImageSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyHeadMirrorImage];
}

- (void)securityEnabledSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeySecurityEnabled];
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTSettingsSecurityEnabledChangedNotification object:nil];
}

- (void)kubiEnabledSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyKubiEnabled];
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTSettingsKubiEnabledChangedNotification object:nil];
}

- (void)kubiMirrorSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyKubiMirror];
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTSettingsKubiSettingsChangedNotification object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
		case PLTTableViewSectionGeneral: return 3;
		case PLTTableViewSectionHead: return 2;
		case PLTTableViewSectionStreetView: return 1;
		case PLTTableViewSectionSecurity: return 3;
		case PLTTableViewSectionKubi: return 4;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView defaultCell];
	switch (indexPath.section) {
		case PLTTableViewSectionGeneral: {
			switch (indexPath.row) {
				case PLTTableViewGeneralAbout: {
					cell = [tableView value1Cell];
					cell.textLabel.text = @"About";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.textAlignment = NSTextAlignmentLeft;
					cell.detailTextLabel.text = @"";
					break; }
				case PLTTableViewGeneralRowHTCalibrationTriggers: {
					cell = [tableView value1Cell];
					cell.textLabel.text = @"HT Cal Triggers";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.textAlignment = NSTextAlignmentLeft;
					NSString *detailText = @"";
					NSUInteger triggers = [(NSNumber *)[DEFAULTS objectForKey:PLTDefaultsKeyHTCalibrationTriggers] unsignedIntegerValue];
					if ((triggers & PLTHeadTrackingCalibrationTriggerShake) && (triggers & PLTHeadTrackingCalibrationTriggerDon)) {
						detailText = @"Shake & Don";
					}
					else if (triggers & PLTHeadTrackingCalibrationTriggerShake) {
						if (IPAD) detailText = @"Shake iPad";
						else detailText = @"Shake iPhone";
					}
					else if (triggers & PLTHeadTrackingCalibrationTriggerDon) {
						detailText = @"Don Headset";
					}
					else {
						detailText = @"None";
					}
					cell.detailTextLabel.text = detailText;
				}
				case PLTTableViewGeneralRowMetricUnits: {
                    SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					switchCell.textLabel.text = @"Metric Units";
					switchCell.target = self;
					switchCell.action = @selector(metricUnitsSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyMetricUnits];
                    break; }
			}
			break; }
			
        case PLTTableViewSectionHead: {
			switch (indexPath.row) {
				case PLTTableViewHeadOverlaysRowGestureDetection: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					cell.textLabel.text = @"Gesture Recognition";
					switchCell.target = self;
					switchCell.action = @selector(gestureRecognitionSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyHeadGestureRecognition];
					return cell;
					break; }
				case PLTTableViewHeadOverlaysRowMirrorImage: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					cell.textLabel.text = @"Mirror Image";
					switchCell.target = self;
					switchCell.action = @selector(mirrorImageSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyHeadMirrorImage];
					return cell;
					break; }
				break; }
			}

		case PLTTableViewSectionStreetView: {
			switch (indexPath.row) {
				case PLTTableViewStreetViewRowLocationOverride: {
					cell = [tableView value1Cell];
					cell.textLabel.text = @"Location";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.textAlignment = NSTextAlignmentLeft;
					NSString *locationName = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
					if ([locationName isEqualToString:@"__none"]) locationName = @"Current Location";
					cell.detailTextLabel.text = locationName;
					break; }
			}
			break; }
			
		case PLTTableViewSectionSecurity: {
			switch (indexPath.row) {
				case PLTTableViewSecurityRowEnabled: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					switchCell.textLabel.text = @"Enabled";
					switchCell.target = self;
					switchCell.action = @selector(securityEnabledSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeySecurityEnabled];
					break; }
				case PLTTableViewSecurityRowDevice: {
					cell = [tableView value1Cell];
					cell.textLabel.text = @"Lock";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.textAlignment = NSTextAlignmentLeft;
					NSDictionary *currentDevice = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice];
					cell.detailTextLabel.text = currentDevice[PLTDefaultsKeySecurityDeviceName];
					break; }
				case PLTTableViewSecurityRowEnroll: {
					cell = [tableView subtitleCell];
					cell.textLabel.text = @"Enroll";
					self.enrollCellDetailTextLabel = cell.detailTextLabel;
					cell.textLabel.textAlignment = NSTextAlignmentCenter;
					break; }
			}
			break; }
			
		case PLTTableViewSectionKubi: {
			switch (indexPath.row) {
				case PLTTableViewKubiRowEnabled: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					switchCell.textLabel.text = @"Enabled";
					switchCell.target = self;
					switchCell.action = @selector(kubiEnabledSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyKubiEnabled];
					break; }
				case PLTTableViewKubiRowDevice: {
					cell = [tableView value1Cell];
					cell.textLabel.text = @"Kubi";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.textAlignment = NSTextAlignmentLeft;
					NSDictionary *currentDevice = [DEFAULTS objectForKey:PLTDefaultsKeyKubiDevice];
					cell.detailTextLabel.text = currentDevice[PLTDefaultsKeyKubiDeviceName];
					break; }
				case PLTTableViewKubiRowMode: {
					cell = [tableView value1Cell];
					cell.textLabel.text = @"Mode";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.textAlignment = NSTextAlignmentLeft;
					PLTKubiPositioningMode mode = [DEFAULTS integerForKey:PLTDefaultsKeyKubiMode];
					NSString *modeString = NSStringFromPLTKubiPositioningMode(mode);
					cell.detailTextLabel.text = modeString;
					break; }
				case PLTTableViewKubiRowMirror: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					switchCell.textLabel.text = @"Mirror";
					switchCell.target = self;
					switchCell.action = @selector(kubiMirrorSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyKubiMirror];
					break; }
			}
			break; }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
		case PLTTableViewSectionGeneral: return @"General";
		case PLTTableViewSectionHead: return @"Head";
		case PLTTableViewSectionStreetView: return @"Street View";
		case PLTTableViewSectionSecurity: return @"Security";
		case PLTTableViewSectionKubi: return @"Kubi";
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
		case PLTTableViewSectionGeneral: {
			switch (indexPath.row) {
				case PLTTableViewGeneralAbout:
				case PLTTableViewGeneralRowHTCalibrationTriggers:
					return YES;
			}
			break; }
		case PLTTableViewSectionStreetView: {
			switch (indexPath.row) {
				case PLTTableViewStreetViewRowLocationOverride: return YES;
			}
			break; }
		case PLTTableViewSectionSecurity: {
			switch (indexPath.row) {
				case PLTTableViewSecurityRowDevice:
				case PLTTableViewSecurityRowEnroll:
					return YES;
			}
			break; }
		case PLTTableViewSectionKubi: {
			switch (indexPath.row) {
				case PLTTableViewKubiRowDevice:
				case PLTTableViewKubiRowMode:
					return YES;
			}
			break; }
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	self.navigationController.delegate = self;
	
	switch (indexPath.section) {
		case PLTTableViewSectionGeneral: {
			switch (indexPath.row) {
				case PLTTableViewGeneralAbout: {
					SettingsAboutViewController *vc = [[SettingsAboutViewController alloc] initWithStyle:UITableViewStyleGrouped];
					[self.navigationController pushViewController:vc animated:YES];
					break; }
				case PLTTableViewGeneralRowHTCalibrationTriggers: {
					HTCalibrationTriggersViewController *vc = [[HTCalibrationTriggersViewController alloc] initWithNibName:nil bundle:nil];
					[self.navigationController pushViewController:vc animated:YES];
					break; }
			}
			break; }
			
		case PLTTableViewSectionStreetView: {
			switch (indexPath.row) {
				case PLTTableViewStreetViewRowLocationOverride: {
					LocationOverrideViewController *controller = [[LocationOverrideViewController alloc] initWithNibName:nil bundle:nil];
					[self.navigationController pushViewController:controller animated:YES];
					break; }
			}
			break; }
			
		case PLTTableViewSectionSecurity: {
			switch (indexPath.row) {
				case PLTTableViewSecurityRowDevice: {
					SelectionListViewController *selectionController = [[SelectionListViewController alloc] initWithNibName:nil bundle:nil];
					selectionController.delegate = self;
					selectionController.title = @"Lock";
					selectionController.tag = PLTSelectionListViewTagSecurityDevice;
					NSString *devicesPlistPath = [[NSBundle mainBundle] pathForResource:@"SecurityDevices" ofType:@"plist"];
					NSArray *devices = [NSArray arrayWithContentsOfFile:devicesPlistPath];
					if (devices) {
						NSMutableArray *deviceNames = [NSMutableArray array];
						NSDictionary *currentDevice = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice];
						NSInteger selectedIndex = -1;
						for (NSInteger i=0; i<[devices count]; i++) { // make sure to enumerate in order since list selection is index-based
							NSDictionary *d = devices[i];
							NSDictionary *listItem = @{@"label": d[PLTDefaultsKeySecurityDeviceName],
													   @"enabled": @(YES),
													   @"context": d};
							[deviceNames addObject:listItem];
							if ([d[PLTDefaultsKeySecurityDeviceName] isEqualToString:currentDevice[PLTDefaultsKeySecurityDeviceName]]) {
								selectedIndex = i;
							}
						}
						selectionController.listItems = deviceNames;
						if (selectedIndex >= 0) {
							selectionController.selectedIndex = selectedIndex;
						}
						[self.navigationController pushViewController:selectionController animated:YES];
					}
					else {
						NSLog(@"*** No Security devices file found! ***");
					}
					break; }
					
				case PLTTableViewSecurityRowEnroll: {
					self.enrollCellDetailTextLabel.text = @"Enrolling...";
					SecurityHelper *sh = [SecurityHelper sharedHelper];
					sh.serverAddress = SECURITY_FIDO_ADDRESS;
					sh.serverUsername = [DEFAULTS objectForKey:PLTDefaultsKeySecurityDevice][PLTDefaultsKeySecurityFIDOUsername];
					sh.serverPassword = SECURITY_FIDO_PASSWORD;
					[sh enroll:self];
					break; }
			}
			break; }
			
		case PLTTableViewSectionKubi: {
			switch (indexPath.row) {
				case PLTTableViewKubiRowDevice: {
					SelectionListViewController *selectionController = [[SelectionListViewController alloc] initWithNibName:nil bundle:nil];
					selectionController.delegate = self;
					selectionController.title = @"Kubi";
					selectionController.tag = PLTSelectionListViewTagKubiDevice;
					NSString *devicesPlistPath = [[NSBundle mainBundle] pathForResource:@"KubiDevices" ofType:@"plist"];
					NSArray *devices = [NSArray arrayWithContentsOfFile:devicesPlistPath];
					if (devices) {
						NSMutableArray *deviceNames = [NSMutableArray array];
						NSDictionary *currentDevice = [DEFAULTS objectForKey:PLTDefaultsKeyKubiDevice];
						NSInteger selectedIndex = -1;
						for (NSInteger i=0; i<[devices count]; i++) { // make sure to enumerate in order since list selection is index-based
							NSDictionary *d = devices[i];
							NSDictionary *listItem = @{@"label": d[PLTDefaultsKeyKubiDeviceName],
													   @"enabled": @(YES),
													   @"context": d};
							[deviceNames addObject:listItem];
							if ([d[PLTDefaultsKeyKubiDeviceName] isEqualToString:currentDevice[PLTDefaultsKeyKubiDeviceName]]) {
								selectedIndex = i;
							}
						}
						selectionController.listItems = deviceNames;
						if (selectedIndex >= 0) {
							selectionController.selectedIndex = selectedIndex;
						}
						[self.navigationController pushViewController:selectionController animated:YES];
					}
					else {
						NSLog(@"*** No Kubi devices file found! ***");
					}
					break; }
					
				case PLTTableViewKubiRowMode: {
					SelectionListViewController *selectionController = [[SelectionListViewController alloc] initWithNibName:nil bundle:nil];
					selectionController.delegate = self;
					selectionController.title = @"Mode";
					selectionController.tag = PLTSelectionListViewTagKubiMode;
					selectionController.listItems = @[@{@"label": NSStringFromPLTKubiPositioningMode(PLTKubiPositioningModeJoystick),
														@"enabled": @(YES),
														@"context": @(PLTKubiPositioningModeJoystick)},
													  @{@"label": NSStringFromPLTKubiPositioningMode(PLTKubiPositioningModeAbsolute),
														@"enabled": @(YES),
														@"context": @(PLTKubiPositioningModeAbsolute)}];
					selectionController.selectedIndex = [DEFAULTS integerForKey:PLTDefaultsKeyKubiMode];
					[self.navigationController pushViewController:selectionController animated:YES];
					break; }
			}
			break; }
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	/*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if (viewController != self) {
			self.displayingOtherView = YES;
		}
		else {
			self.displayingOtherView = NO;
		}
	}*/
	
	if (viewController != self) {
		viewController.preferredContentSize = navigationController.contentSizeForViewInPopover;
	}
}

#pragma mark - SelectionListViewControllerDelegate

- (void)selectionListViewController:(SelectionListViewController *)theController didSelectItemWithLabel:(NSString *)label context:(id)context index:(NSUInteger)index
{
	NSLog(@"selectionListViewController:didSelectItemWithLabel: %@ context: %@ index:%ld", label, context, (unsigned long)index);
	
    switch (theController.tag) {
		case PLTSelectionListViewTagSecurityDevice: {
			[DEFAULTS setObject:context forKey:PLTDefaultsKeySecurityDevice];
			[[NSNotificationCenter defaultCenter] postNotificationName:PLTSettingsSecurityDeviceChangedNotification object:nil];
			break; }
			
		case PLTSelectionListViewTagKubiDevice: {
			[DEFAULTS setObject:context forKey:PLTDefaultsKeyKubiDevice];
			[[NSNotificationCenter defaultCenter] postNotificationName:PLTSettingsKubiDeviceChangedNotification object:nil];
			break; }
			
		case PLTSelectionListViewTagKubiMode: {
			[DEFAULTS setInteger:[context integerValue] forKey:PLTDefaultsKeyKubiMode];
			[[NSNotificationCenter defaultCenter] postNotificationName:PLTSettingsKubiSettingsChangedNotification object:nil];
			break; }
    }
}

#pragma mark - SecurityHelperEnrollDelegate

- (void)securityHelperDidEnroll:(SecurityHelper *)theHelper
{
	self.enrollCellDetailTextLabel.text = @"Successfully enrolled";
}

- (void)securityHelper:(SecurityHelper *)theHelper didEncounterErrorEnrolling:(NSError *)error
{
	//self.enrollCellDetailTextLabel.text = [NSString stringWithFormat:@"Error enrolling: %@", error];
	self.enrollCellDetailTextLabel.text = @"Error. Restart headset.";
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self action:@selector(doneButton:)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
	self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[DEFAULTS synchronize];
	self.preferredContentSize = self.navigationController.contentSizeForViewInPopover;
    [self.tableView reloadData];
	
	self.enrollCellDetailTextLabel.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [DEFAULTS synchronize];
}

@end
