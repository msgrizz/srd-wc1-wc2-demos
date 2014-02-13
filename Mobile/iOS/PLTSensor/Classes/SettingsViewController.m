//
//  SettingsViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "PLTContextServer.h"
#import "SwitchTableViewCell.h"
#import "AppDelegate.h"
#import "SelectionListViewController.h"
#import "LocationOverrideViewController.h"
#import "ServerSettingsViewController.h"
#import "UITableView+Cells.h"
#import "ServerStatusViewController.h"
#import "StatusWatcher.h"
#import "ConfigTempViewController.h"
#import "PLTHeadsetManager.h"
#import "HTCalibrationTriggersViewController.h"


NSString *const PLTSettingsPopoverDidDismissNotification =		@"PLTSettingsPopoverDidDismissNotification";


typedef NS_ENUM(NSUInteger, PLTTableViewSection) {
    PLTTableViewSectionContextServerStatus,
    PLTTableViewSectionContextServerConfiguration,
	PLTTableViewSectionGeneral,
    PLTTableViewSection3DHead,
    //PLTTableViewSectionSensors,
    //PLTTableViewSectionStreetViewFirst,
    //PLTTableViewSectionStreetViewPrecache
};

typedef NS_ENUM(NSUInteger, PLTTableViewContextServerConfigurationRow) {
    PLTTableViewContextServerConfigurationRowServerSettings,
    PLTTableViewContextServerConfigurationRowLocationOverride
};

typedef NS_ENUM(NSUInteger, PLTTableViewGeneralRow) {
	PLTTableViewGeneralRowHTCalibrationTriggers,
	PLTTableViewGeneralRowMetricUnits,
    PLTTableViewGeneralRowStatusIcons
};

typedef NS_ENUM(NSUInteger, PLTTableView3DHeadOverlaysRow) {
	PLTTableView3DHeadOverlaysRowGestureDetection,
	PLTTableView3DHeadOverlaysRowMirrorImage
    //PLTTableView3DHeadOverlaysRowDebugOverlay
};

//typedef NS_ENUM(NSUInteger, PLTTableViewSensorsRow) {
//    PLTTableViewSensorsRowTemperatureCalibration
//};

//typedef NS_ENUM(NSUInteger, PLTTableViewStreetViewOverlaysRow) {
//	PLTTableViewStreetViewOverlaysRowAngularResolution,
//    PLTTableViewStreetViewOverlaysRowInfoOverlay,
//    PLTTableViewStreetViewOverlaysRowDebugOverlay
//};

typedef NS_ENUM(NSUInteger, PLTSelectionListViewTag) {
    PLTSelectionListViewTagAngularResolution
};

typedef NS_ENUM(NSUInteger, PLTAlertViewTag) {
    PLTAlertViewTagMissingCredentials,
    PLTAlertViewTagAuthenticationFailed
};


@interface SettingsViewController () <PLTContextServerDelegate, ServerStatusViewControllerDelegate,
SelectionListViewControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>

//- (void)updatePopoverContentViewSize;
//- (void)connectToContextServer;
- (void)disconnectFromContextServer;
- (void)unregisterDeviceWithContextServer;
- (void)startConnectionTimer;
- (void)stopConnectionTimer;
- (void)connectionTimer:(NSTimer *)theTimer;
- (void)statusIconsSwitchChanged:(UISwitch *)theSwitch;
- (void)metricUnitsSwitchChanged:(UISwitch *)theSwitch;
- (void)gestureRecognitionSwitch:(UISwitch *)theSwitch;
- (void)threeDHeadOverlayDebugSwitch:(UISwitch *)theSwitch;
- (void)streetViewOverlayInfoSwitchChanged:(UISwitch *)theSwitch;
- (void)streetViewOverlayDebugSwitchChanged:(UISwitch *)theSwitch;
- (void)contextServerDidChangeStateNotification:(NSNotification *)note;

@property(nonatomic,assign) BOOL		deviceRegistered;
@property(nonatomic,strong) NSTimer		*connectionTimer;
@property(nonatomic,assign) BOOL		displayingOtherView;
@property(nonatomic,assign) BOOL		connectedCellIsLarge;
@property(nonatomic,strong) UIAlertView	*authFailureAlertView;
//@property(nonatomic,assign) BOOL		isAnimatingIn;

@end


@implementation SettingsViewController

#pragma mark - Public

- (IBAction)doneButton:(id)sender
{
	[self.delegate settingsViewControllerDidEnd:self];
}

#pragma mark - Private

//- (void)updatePopoverContentViewSize
//{
//	NSLog(@"updatePopoverContentViewSize");
//	if (!self.isAnimatingIn) {
//		if ([[PLTContextServer sharedContextServer] state] >= PLT_CONTEXT_SERVER_AUTHENTICATED) {
//			NSLog(@"disconnected(set large), %@",(self.connectedCellIsLarge ? @"YES" : @"NO"));
//			if (!self.connectedCellIsLarge) {
//				NSLog(@"yessir");
//				// resize large
//				[[self.delegate popoverControllerForSettingsViewController:self] setPopoverContentSize:self.navigationController.contentSizeForViewInPopover animated:YES];
//				NSLog(@"setting YES");
//				self.connectedCellIsLarge = YES;
//			}
//		}
//		else {
//			NSLog(@"disconnected(set small), %@",(self.connectedCellIsLarge ? @"YES" : @"NO"));
//			if (self.connectedCellIsLarge) {
//				NSLog(@"yessir");
//				// resize small
//				[[self.delegate popoverControllerForSettingsViewController:self] setPopoverContentSize:self.navigationController.contentSizeForViewInPopover animated:YES];
//				NSLog(@"setting NO");
//				self.connectedCellIsLarge = NO;
//			}
//		}
//	}
//	else {
//		NSLog(@"animating.");
//	}
//}

- (void)disconnectFromContextServer
{
    [[PLTContextServer sharedContextServer] closeConnection];
}

- (void)unregisterDeviceWithContextServer
{
    NSLog(@"registerDeviceWithContextServer");
	
	NSDictionary *payload = @{@"device": @{@"deviceId" : [[UIDevice currentDevice].identifierForVendor UUIDString]}};
    PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_REGISTER_DEVICE messageId:UNREGISTER_DEVICE payload:payload];
    [[PLTContextServer sharedContextServer] sendMessage:message cacheIfServerIsOffline:YES];
}

- (void)startConnectionTimer
{
    PLTContextServer *server = [PLTContextServer sharedContextServer];
    if ((server.state == PLT_CONTEXT_SERVER_AUTHENTICATED) || (server.state == PLT_CONTEXT_SERVER_REGISTERING) || (server.state == PLT_CONTEXT_SERVER_REGISTERED)) {
        if (![self.connectionTimer isValid]) {
            self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:YES];
            [self connectionTimer:self.connectionTimer];
        }
    }
}

- (void)stopConnectionTimer
{
    if ([self.connectionTimer isValid]) {
        [self.connectionTimer invalidate];
        self.connectionTimer = nil;
    }
}

- (void)connectionTimer:(NSTimer *)theTimer
{
    PLTContextServer *server = [PLTContextServer sharedContextServer];
    
    if ((server.state == PLT_CONTEXT_SERVER_AUTHENTICATED) || (server.state == PLT_CONTEXT_SERVER_REGISTERING) || (server.state == PLT_CONTEXT_SERVER_REGISTERED)) {
        
        NSTimeInterval connectionSeconds = [[NSDate date] timeIntervalSinceDate:server.authenticationDate];
        
        NSTimeInterval secondsInAMinute = 60;
        NSTimeInterval secondsInAnHour  = 60 * secondsInAMinute;
        NSTimeInterval secondsInADay    = 24 * secondsInAnHour;
        
        // extract days
        NSTimeInterval days = floor(connectionSeconds / secondsInADay);
        
        // extract hours
        NSTimeInterval hourSeconds = (NSUInteger)connectionSeconds % (NSUInteger)secondsInADay;
        NSTimeInterval hours = floor(hourSeconds / secondsInAnHour);
        
        // extract minutes
        NSTimeInterval minuteSeconds = (NSUInteger)hourSeconds % (NSUInteger)secondsInAnHour;
        NSTimeInterval minutes = floor(minuteSeconds / secondsInAMinute);
        
        // extract the remaining seconds
        NSTimeInterval remainingSeconds = (NSUInteger)minuteSeconds % (NSUInteger)secondsInAMinute;
        NSTimeInterval seconds = ceil(remainingSeconds);
        
        //NSLog(@"%.2fd %.2fh %.2fm %.2fs", days, hours, minutes, seconds);
        self.connectionTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", lround(minutes), lround(seconds)];
        if (lround(hours)) self.connectionTimeLabel.text = [NSString stringWithFormat:@"%02ld:%@", lround(hours), self.connectionTimeLabel.text];
        if (lround(days)) self.connectionTimeLabel.text = [NSString stringWithFormat:@"%02ld:%@", lround(days), self.connectionTimeLabel.text];
    }
    else {
        NSLog(@"Not connected. Killing connection timer.");
        [self stopConnectionTimer];
    }
}

- (void)statusIconsSwitchChanged:(UISwitch *)theSwitch
{
	if (theSwitch.on) {
		[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyShowStatusIcons];
		[[StatusWatcher sharedWatcher] setActiveNavigationBar:self.navigationController.navigationBar animated:YES delayed:NO];
	}
	else {
		[[StatusWatcher sharedWatcher] setActiveNavigationBar:nil animated:YES];
		[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyShowStatusIcons];
	}
}

- (void)metricUnitsSwitchChanged:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyMetricUnits];
}

- (void)gestureRecognitionSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyGestureRecognition];
}

- (void)mirrorImageSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKey3DHeadMirrorImage];
}

- (void)threeDHeadOverlayDebugSwitch:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKey3DHeadDebugOverlay];
}

- (void)streetViewOverlayInfoSwitchChanged:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyStreetViewInfoOverlay];
}

- (void)streetViewOverlayDebugSwitchChanged:(UISwitch *)theSwitch
{
	[DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeyStreetViewDebugOverlay];
}

- (void)contextServerDidChangeStateNotification:(NSNotification *)note
{
	NSInteger state = [[note userInfo][PLTContextServerDidChangeStateNotificationInfoKeyState] intValue];
	//NSLog(@"state: %d",state);
	NSIndexPath *path = [NSIndexPath indexPathForRow:PLTTableViewContextServerConfigurationRowServerSettings
										   inSection:PLTTableViewSectionContextServerStatus];
	// these tend to come in pretty quickly when auto-registering, and animating the table view that quickly causes glitches
	// we don't really even want animation once the cell is expanded into the "connected" state, anyway, so don't animate after that point.
	if (state > PLT_CONTEXT_SERVER_AUTHENTICATED) {
		[self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
	}
	else {
		[self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case PLTTableViewSectionContextServerStatus: return 1;
		case PLTTableViewSectionContextServerConfiguration: return 2;
		case PLTTableViewSectionGeneral: return 3;
        case PLTTableViewSection3DHead: return 2;
        //case PLTTableViewSectionSensors: return 1;
        //case PLTTableViewSectionStreetViewFirst: return 3;
        //case PLTTableViewSectionStreetViewPrecache: return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView defaultCell];
	switch (indexPath.section) {
        case PLTTableViewSectionContextServerStatus: {
			PLTContextServer *server = [PLTContextServer sharedContextServer];
            switch ([server state]) {
                case PLT_CONTEXT_SERVER_CLOSED: { // disconnected ("Connect")
                case PLT_CONTEXT_SERVER_CLOSING:
                    cell.textLabel.text = @"Connect";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
					[cell.textLabel sizeToFit];
					break; }
                case PLT_CONTEXT_SERVER_OPENING: { // "Connecting..."
                case PLT_CONTEXT_SERVER_OPEN:
                    cell.textLabel.text = @"Connecting...";
                    //cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityIndicator startAnimating];
                    cell.accessoryView = activityIndicator;
                    break; }
                case PLT_CONTEXT_SERVER_AUTHENTICATING: { // "Authenticating..."
                    cell.textLabel.text = @"Authenticating...";
                    //cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityIndicator startAnimating];
                    cell.accessoryView = activityIndicator;
                    break; }
                case PLT_CONTEXT_SERVER_AUTHENTICATED: // "Connected"
					cell = self.connectionStatusCell;
					self.connectionUsernameLabel.text = server.username;
					self.connectionStatusLabel.text = @"Connected";
					break;
                case PLT_CONTEXT_SERVER_REGISTERING: // "Registering"
					cell = self.connectionStatusCell;
					self.connectionUsernameLabel.text = server.username;
					self.connectionStatusLabel.text = @"Registering...";
					break;
				case PLT_CONTEXT_SERVER_REGISTERED: // "Registered"
                    cell = self.connectionStatusCell;
					self.connectionUsernameLabel.text = server.username;
					self.connectionStatusLabel.text = @"Registered";
                    break;
            }
			//[self updatePopoverContentViewSize];
			break; }
		case PLTTableViewSectionGeneral: {
			switch (indexPath.row) {
				case PLTTableViewGeneralRowStatusIcons: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					switchCell.textLabel.text = @"Status Icons";
					switchCell.target = self;
					switchCell.action = @selector(statusIconsSwitchChanged:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyShowStatusIcons];
					break; }
				case PLTTableViewGeneralRowMetricUnits: {
                    SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					switchCell.textLabel.text = @"Metric Units";
					switchCell.target = self;
					switchCell.action = @selector(metricUnitsSwitchChanged:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyMetricUnits];
                    break; }
				case PLTTableViewGeneralRowHTCalibrationTriggers: {
					cell = [tableView value1Cell];
                    cell.textLabel.text = @"HT Cal Triggers";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
					NSString *detailText = @"";
					NSUInteger triggers = [(NSNumber *)[DEFAULTS objectForKey:PLTDefaultsKeyHeadTrackingCalibrationTriggers] unsignedIntegerValue];
					if ((triggers & PLTHeadTrackingCalibrationTriggerShake) && (triggers & PLTHeadTrackingCalibrationTriggerDon)) {
						detailText = @"Shake & Don";
					}
					else if (triggers & PLTHeadTrackingCalibrationTriggerShake) {
						
						if (DEVICE_IPAD) detailText = @"Shake iPad";
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
			}
			break; }
        case PLTTableViewSectionContextServerConfiguration: {
            switch (indexPath.row) {
                case PLTTableViewContextServerConfigurationRowServerSettings:
                    cell.textLabel.text = @"Server Settings";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    break;
                case PLTTableViewContextServerConfigurationRowLocationOverride: {
                    cell = [tableView value1Cell];
                    cell.textLabel.text = @"Location Override";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    NSString *locationName = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
                    if ([locationName isEqualToString:@"__none"]) locationName = @"None";
                    cell.detailTextLabel.text = locationName;
                    break; }
            }
            break; }
        case PLTTableViewSection3DHead: {
			switch (indexPath.row) {
				case PLTTableView3DHeadOverlaysRowGestureDetection: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					cell.textLabel.text = @"Gesture Recognition";
					switchCell.target = self;
					switchCell.action = @selector(gestureRecognitionSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyGestureRecognition];
					return cell;
					break; }
				case PLTTableView3DHeadOverlaysRowMirrorImage: {
					SwitchTableViewCell *switchCell = [tableView switchCell];
					cell = switchCell;
					cell.textLabel.text = @"Mirror Image";
					switchCell.target = self;
					switchCell.action = @selector(mirrorImageSwitch:);
					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKey3DHeadMirrorImage];
					return cell;
					break; }
//				case PLTTableView3DHeadOverlaysRowDebugOverlay: {
//					SwitchTableViewCell *switchCell = [tableView switchCell];
//					cell = switchCell;
//					cell.textLabel.text = @"Debug Overlay";
//					switchCell.target = self;
//					switchCell.action = @selector(threeDHeadOverlayDebugSwitch:);
//					switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKey3DHeadDebugOverlay];
//					break; }
				break; }
			}
//        case PLTTableViewSectionSensors:
//            switch (indexPath.row) {
//                case PLTTableViewSensorsRowTemperatureCalibration:
//                    cell.textLabel.text = @"Temperature Calibration";
//                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
//                    break;
//            }
//            break;
//        case PLTTableViewSectionStreetViewFirst:
//            switch (indexPath.row) {
//                case PLTTableViewStreetViewOverlaysRowInfoOverlay: {
//                    SwitchTableViewCell *cell = [tableView switchCell];
//                    cell.textLabel.text = @"Address Overlay";
//					cell.target = self;
//                    cell.action = @selector(streetViewOverlayInfoSwitchChanged:);
//                    cell.on = [DEFAULTS boolForKey:PLTDefaultsKeyStreetViewInfoOverlay];
//                    return cell;
//                    break; }
//                case PLTTableViewStreetViewOverlaysRowDebugOverlay: {
//                    SwitchTableViewCell *cell = [tableView switchCell];
//                    cell.textLabel.text = @"Debug Overlay";
//					cell.target = self;
//                    cell.action = @selector(streetViewOverlayDebugSwitchChanged:);
//                    cell.on = [DEFAULTS boolForKey:PLTDefaultsKeyStreetViewDebugOverlay];
//                    return cell;
//                    break; }
//                case PLTTableViewStreetViewOverlaysRowAngularResolution: {
//                    cell = [tableView value1Cell];
//                    cell.textLabel.text = @"Angular Resolution";
//                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
//                    NSString *detailString;
//                    switch ([DEFAULTS integerForKey:PLTDefaultsKeyStreetViewRoundingMultiple]) {
//                        case 2:
//                            detailString = @"High";
//                            break;
//                        case 5:
//                            detailString = @"Medium";
//                            break;
//                        case 10:
//                            detailString = @"Low";
//                            break;
//                    }
//                    cell.detailTextLabel.text = detailString;
//                    break; }
//            }
//            break;
//        case PLTTableViewSectionStreetViewPrecache:
//            cell.textLabel.text = @"Precache Current Location";
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            cell.textLabel.textAlignment = NSTextAlignmentCenter;
//            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case PLTTableViewSectionContextServerStatus:
            return @"Context Server";
            break;
        case PLTTableViewSectionContextServerConfiguration:
            return nil;
            break;
	case PLTTableViewSectionGeneral:
			return @"General";
			break;
        case PLTTableViewSection3DHead:
            return @"3D Head";
            break;
//        case PLTTableViewSectionSensors:
//            return @"Sensors";
//            break;
//        case PLTTableViewSectionStreetViewFirst:
//            return @"Street View";
//            break;
//        case PLTTableViewSectionStreetViewPrecache:
//            return nil;
//            break;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case PLTTableViewSectionContextServerStatus:
			return YES;
        case PLTTableViewSectionContextServerConfiguration:
			return YES;
		case PLTTableViewSectionGeneral:
			if (indexPath.row == PLTTableViewGeneralRowHTCalibrationTriggers) return YES;
			return NO;
//		case PLTTableViewSectionSensors:
//			return YES;
//        case PLTTableViewSectionStreetViewFirst: {
//            switch (indexPath.row) {
//                case PLTTableViewStreetViewOverlaysRowAngularResolution:
//					return YES;
//            }
//            break; }
//        case PLTTableViewSectionStreetViewPrecache:
//			return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	self.navigationController.delegate = self;
    
    switch (indexPath.section) {
        case PLTTableViewSectionContextServerStatus: {
            PLTContextServer *server = [PLTContextServer sharedContextServer];
            switch ([server state]) {
                case PLT_CONTEXT_SERVER_AUTHENTICATED:
                case PLT_CONTEXT_SERVER_REGISTERING:
                case PLT_CONTEXT_SERVER_REGISTERED: {
                    ServerStatusViewController *controller = [[ServerStatusViewController alloc] initWithNibName:nil bundle:nil];
                    controller.delegate = self;
                    [self.navigationController pushViewController:controller animated:YES];
                    break; }
                default: {
                    if (!([[DEFAULTS objectForKey:PLTDefaultsKeyContextServerUsername] length] && [[DEFAULTS objectForKey:PLTDefaultsKeyContextServerPassword] length])) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Credentials"
                                                                        message:@"Please set a username and password in \"Server Settings.\""
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        alert.tag = PLTAlertViewTagMissingCredentials;
                        [alert show];
                    }
                    else {
						[(AppDelegate *)[UIApplication sharedApplication].delegate connectToContextServer];
					}
                    break; }
            }
            break; }
        case PLTTableViewSectionContextServerConfiguration: {
            switch (indexPath.row) {
                case PLTTableViewContextServerConfigurationRowServerSettings: {
                    ServerSettingsViewController *controler = [[ServerSettingsViewController alloc] initWithNibName:nil bundle:nil];
                    [self.navigationController pushViewController:controler animated:YES];
                    break; }
                case PLTTableViewContextServerConfigurationRowLocationOverride: {
                    LocationOverrideViewController *controller = [[LocationOverrideViewController alloc] initWithNibName:nil bundle:nil];
                    [self.navigationController pushViewController:controller animated:YES];
                    break; }
            }
            break; }
		case PLTTableViewSectionGeneral:
			if (indexPath.row == PLTTableViewGeneralRowHTCalibrationTriggers) {
				HTCalibrationTriggersViewController *vc = [[HTCalibrationTriggersViewController alloc] initWithNibName:nil bundle:nil];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
//        case PLTTableViewSectionStreetViewFirst: {
//            switch (indexPath.row) {
//                case PLTTableViewStreetViewOverlaysRowAngularResolution: {
//                    SelectionListViewController *listController = [[SelectionListViewController alloc] initWithNibName:nil bundle:nil];
//                    listController.delegate = self;
//                    listController.tag = PLTSelectionListViewTagAngularResolution;
//                    listController.title = @"Angular Resolution";
//                    listController.listItems = @[
//												 @{@"label" : @"High", @"context" : @2, @"enabled" : @NO},
//			 @{@"label" : @"Medium", @"context" : @5, @"enabled" : @YES},
//			 @{@"label" : @"Low", @"context" : @10, @"enabled" : @YES}];
//                    // this is kind of a crappy way to do this... how to improve it?
//                    switch ([DEFAULTS integerForKey:PLTDefaultsKeyStreetViewRoundingMultiple]) {
//                        case 2:
//                            listController.selectedIndex = 0;
//                            break;
//                        case 5:
//                            listController.selectedIndex = 1;
//                            break;
//                        case 10:
//                            listController.selectedIndex = 2;
//                            break;
//                        default:
//                            break;
//                    }
//                    [self.navigationController pushViewController:listController animated:YES];
//                    break; }
//            }
//            break; }
//        case PLTTableViewSectionStreetViewPrecache:
//            [self.delegate settingsViewControllerDidClickStreetViewPrecache:self];
//            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([[PLTContextServer sharedContextServer] state]) {
        case PLT_CONTEXT_SERVER_AUTHENTICATED:
        case PLT_CONTEXT_SERVER_REGISTERING:
        case PLT_CONTEXT_SERVER_REGISTERED:
            if ((indexPath.section==0) && (indexPath.row==0)) return 62;
        default:
            return 44;
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if (viewController != self) {
			self.displayingOtherView = YES;
			[[StatusWatcher sharedWatcher] setActiveNavigationBar:nil animated:YES];
		}
		else {
			self.displayingOtherView = NO;
		}
	}
	
	if (viewController != self) {
		viewController.contentSizeForViewInPopover = navigationController.contentSizeForViewInPopover;
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case PLTAlertViewTagMissingCredentials:
        case PLTAlertViewTagAuthenticationFailed: {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            });
            break; }
    }
}

#pragma mark - PLTContextServerDelegate

- (void)serverDidOpen:(PLTContextServer *)sender
{
    NSLog(@"Web Socket opened.");
    //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)server:(PLTContextServer *)sender didAuthenticate:(BOOL)authenticationWasSuccessful
{
    if (authenticationWasSuccessful) {
        NSLog(@"Authentication succeeded.");
		if ([DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoRegister]) {
			[(AppDelegate *)[UIApplication sharedApplication].delegate registerDeviceWithContextServer];
		}
		else {
			[self startConnectionTimer];
		}
    }
    else {
        NSLog(@"Authentication failed!");
        
		if (!self.authFailureAlertView) {
			self.authFailureAlertView = [[UIAlertView alloc] initWithTitle:@"Authentication Failed"
																   message:@"Please check your username and password in \"Server Settings.\""
																  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			self.authFailureAlertView.tag = PLTAlertViewTagAuthenticationFailed;
			[self.authFailureAlertView show];
		}
    }
	
	//[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)server:(PLTContextServer *)sender didRegister:(BOOL)registrationWasSuccessful
{
    if (registrationWasSuccessful) {
        NSLog(@"Registration succeeded.");
        [self startConnectionTimer];
		//[self.tableView reloadData];
    }
    else {
        NSLog(@"Registration failed!");
    }
    
	//[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) server:(PLTContextServer *)sender didUnregister:(BOOL)unregistrationWasSuccessful
{
	NSLog(@"serverDidUnregister: %@",(unregistrationWasSuccessful ? @"YES" : @"NO"));
}

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
    printf("+");
//    NSLog(@"Received Message...\n");
//    NSLog(@"JSON: %@",[message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]);
	
    // registerDeviceWithContextServer
    if ([message hasType:@"registerDeviceWithContextServer"]) {
        // do stuff here...
        self.deviceRegistered = YES;
        //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    // event
    else if ([message hasType:@"event"]) {
        // do stuff here...
    }
    // setting
    else if ([message hasType:@"setting"]) {
        // do stuff here...
    }
    // command
    else if ([message hasType:@"command"]) {
        // do stuff here...
    }
    // exception
    else if ([message hasType:@"exception"]) {
        NSString *alertMessage = [NSString stringWithFormat:@"id: %@\nmessage: %@", message.messageId, [message.payload objectForKey:@"message"]];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Context Server Exception"
                              message:alertMessage
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    // unknown
    else {
        NSString *alertMessage = [NSString stringWithFormat:@"The message type\"%@\" is not valid.", message.type];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Unknown Message Type"
                              message:alertMessage
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)server:(PLTContextServer *)sender didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"Web Socket closed: %@", reason);
    
    if ((!code) && [[self.navigationController topViewController] isKindOfClass:[ServerStatusViewController class]]) {
        [self.navigationController popToViewController:self animated:YES];
    }
    
	//[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)server:(PLTContextServer *)sender didFailWithError:(NSError *)error
{
    NSLog(@"Web Socket failed with error: %@", error);
	//[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ServerStatusViewControllerDelegate

- (void)serverStatusViewController:(ServerStatusViewController *)theController didRegister:(BOOL)flag
{
    if (flag) [(AppDelegate *)[UIApplication sharedApplication].delegate registerDeviceWithContextServer];
    else [self unregisterDeviceWithContextServer];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)serverStatusViewControllerDidDisconnect:(ServerStatusViewController *)theController;
{
    [self disconnectFromContextServer];
}

#pragma mark - SelectionListViewControllerDelegate

- (void)selectionListViewController:(SelectionListViewController *)theController didSelectItemWithLabel:(NSString *)label context:(id)context index:(NSUInteger)index
{
    switch (theController.tag) {
        case PLTSelectionListViewTagAngularResolution:
            [DEFAULTS setInteger:[(NSNumber *)context integerValue] forKey:PLTDefaultsKeyStreetViewRoundingMultiple];
            break;
    }
}

//#pragma mark - ConfigTempViewControllerDelegate
//
//- (void)configTempViewController:(ConfigTempViewController *)controller didAcceptMetric:(BOOL)celcius ambientTemp:(float)ambientTempCelcius
//{
//	
//}

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
	
	//self.isAnimatingIn = YES;
	
	self.contentSizeForViewInPopover = self.navigationController.contentSizeForViewInPopover;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[[StatusWatcher sharedWatcher] setActiveNavigationBar:self.navigationController.navigationBar animated:self.displayingOtherView delayed:self.displayingOtherView];
	}
    [[PLTContextServer sharedContextServer] addDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextServerDidChangeStateNotification:)
												 name:PLTContextServerDidChangeStateNotification object:nil];
    [self.tableView reloadData];
    [self startConnectionTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:YES];
	//self.isAnimatingIn = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTContextServerDidChangeStateNotification object:nil];
    [DEFAULTS synchronize];
}

@end
