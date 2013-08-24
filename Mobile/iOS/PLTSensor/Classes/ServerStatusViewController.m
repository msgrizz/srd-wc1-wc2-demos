//
//  ServerStatusViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/2/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ServerStatusViewController.h"
#import "UITableView+Cells.h"
#import "SwitchTableViewCell.h"
#import "PLTContextServer.h"
#import "AppDelegate.h"
#import "ServerLogViewController.h"


@interface ServerStatusViewController () <PLTContextServerDelegate>

- (void)registeredSwitchChanged:(UISwitch *)theSwitch;
//- (void)oldSkewlSwitchChanged:(UISwitch *)theSwitch;
- (void)contextServerDidChangeStateNotification:(NSNotification *)note;

@property(nonatomic,strong) UISwitch	*registeredSwitch;

@end


@implementation ServerStatusViewController

#pragma mark - Private

- (void)registeredSwitchChanged:(UISwitch *)theSwitch
{
    [self.delegate serverStatusViewController:self didRegister:theSwitch.on];
	
//	NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
//	if (theSwitch.on) {
//		[self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
//	}
//	else {
//		[self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
//	}
}

//- (void)oldSkewlSwitchChanged:(UISwitch *)theSwitch
//{
//    [DEFAULTS setBool:theSwitch.on forKey:PLTDefaultsKeySendOldSkewlEvents];
//}

@dynamic registeredSwitch;
- (UISwitch *)registeredSwitch
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    return (UISwitch *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

- (void)contextServerDidChangeStateNotification:(NSNotification *)note
{
	NSInteger state = [[note userInfo][PLTContextServerDidChangeStateNotificationInfoKeyState] integerValue];
	NSLog(@"contextServerDidChangeStateNotification: %d", state);
	switch (state) {
		case PLT_CONTEXT_SERVER_AUTHENTICATED:
		case PLT_CONTEXT_SERVER_REGISTERING:
		case PLT_CONTEXT_SERVER_REGISTERED:
			break;
		default:
			[self.navigationController popToViewController:self animated:YES];
			break;
	}
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: {
//			int state = [PLTContextServer sharedContextServer].state;
//			return (((state >= PLT_CONTEXT_SERVER_REGISTERING) && (state < PLT_CONTEXT_SERVER_UNREGISTERING)) ? 3 : 2);
			return 2;
            break; }
        case 1:
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView defaultCell];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    SwitchTableViewCell *switchCell = [tableView switchCell];
                    cell = switchCell;
                    switchCell.target = self;
                    switchCell.action = @selector(registeredSwitchChanged:);
                    switchCell.on = ([PLTContextServer sharedContextServer].state == PLT_CONTEXT_SERVER_REGISTERED);
                    cell.textLabel.text = @"Registered";
                    break; }
				default: {
//					BOOL registering = ([PLTContextServer sharedContextServer].state >= PLT_CONTEXT_SERVER_REGISTERING);
//					if ((indexPath.row==2) || ((indexPath.row==1) && !registering)) {
						cell.textLabel.text = @"Log";
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						break;
//					}
//					else {
//						SwitchTableViewCell *switchCell = [tableView switchCell];
//						cell = switchCell;
//						switchCell.target = self;
//						switchCell.action = @selector(oldSkewlSwitchChanged:);
//						switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeySendOldSkewlEvents];
//						cell.textLabel.text = @"Send Old School Events";
//						cell.textLabel.adjustsFontSizeToFitWidth = YES;
//					}
				}
            }
            break; }
        case 1: {
            cell = [tableView buttonCell];
            cell.textLabel.text = @"Disconnect";
            break; }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row) return YES;
            break;
        case 1:
        default:
            return YES;
            break;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            ServerLogViewController *controller = [[ServerLogViewController alloc] initWithNibName:nil bundle:nil];
			[self.navigationController pushViewController:controller animated:YES];
            break; }
        case 1:
        default:
            [self.delegate serverStatusViewControllerDidDisconnect:self];
            break;
    }
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didRegister:(BOOL)registrationWasSuccessful
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ServerStatusViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Server Status";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PLTContextServer sharedContextServer] addDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextServerDidChangeStateNotification:)
												 name:PLTContextServerDidChangeStateNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[PLTContextServer sharedContextServer] removeDelegate:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTContextServerDidChangeStateNotification object:nil];
}

@end
