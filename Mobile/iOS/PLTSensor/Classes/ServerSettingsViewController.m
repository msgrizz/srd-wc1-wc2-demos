//
//  ServerSettingsViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/1/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ServerSettingsViewController.h"
#import "UITableView+Cells.h"
#import "SwitchTableViewCell.h"
#import "AppDelegate.h"


typedef NS_ENUM(NSUInteger, PLTServerSettingsTableSection) {
    PLTServerSettingsTableSectionConnectivity,
    PLTServerSettingsTableSectionCredentials,
	PLTServerSettingsTableSectionAuto
};

typedef NS_ENUM(NSUInteger, PLTServerSettingsTableConnectivityRow) {
    PLTServerSettingsTableConnectivityRowAddress,
    PLTServerSettingsTableConnectivityRowPort,
    PLTServerSettingsTableConnectivityRowSecure
};

typedef NS_ENUM(NSUInteger, PLTServerSettingsTableCredentialsRow) {
    PLTServerSettingsTableCredentialsRowUsername,
    PLTServerSettingsTableCredentialsRowPassword
};

typedef NS_ENUM(NSUInteger, PLTServerSettingsTableAutoRow) {
    PLTServerSettingsTableAutoRowConnect,
    PLTServerSettingsTableAutoRowRegister
};

@interface ServerSettingsViewController () <UITextFieldDelegate>

- (void)switchCell:(id)sender;
- (void)saveToDefaults;

@property(nonatomic,readonly)   UITextField     *addressTextField;
@property(nonatomic,readonly)   UITextField     *portTextField;
@property(nonatomic,readonly)   UISwitch        *secureSwitch;
@property(nonatomic,readonly)   UITextField     *usernameTextField;
@property(nonatomic,readonly)   UITextField     *passwordTextField;
@property(nonatomic,readonly)   UISwitch        *autoConnectSwitch;
@property(nonatomic,readonly)   UISwitch        *autoRegisterSwitch;

@end


@implementation ServerSettingsViewController

@dynamic addressTextField;
- (UITextField *)addressTextField
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableConnectivityRowAddress
										   inSection:PLTServerSettingsTableSectionConnectivity];
    return (UITextField *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

@dynamic portTextField;
- (UITextField *)portTextField
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableConnectivityRowPort
										   inSection:PLTServerSettingsTableSectionConnectivity];
    return (UITextField *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

@dynamic secureSwitch;
- (UISwitch *)secureSwitch
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableConnectivityRowSecure
										   inSection:PLTServerSettingsTableSectionConnectivity];
    return (UISwitch *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

@dynamic usernameTextField;
- (UITextField *)usernameTextField
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableCredentialsRowUsername
										   inSection:PLTServerSettingsTableSectionCredentials];
    return (UITextField *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

@dynamic passwordTextField;
- (UITextField *)passwordTextField
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableCredentialsRowPassword
										   inSection:PLTServerSettingsTableSectionCredentials];
    return (UITextField *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

@dynamic autoConnectSwitch;
- (UISwitch *)autoConnectSwitch
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableAutoRowConnect
										   inSection:PLTServerSettingsTableSectionAuto];
    return (UISwitch *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

@dynamic autoRegisterSwitch;
- (UISwitch *)autoRegisterSwitch
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableAutoRowRegister
										   inSection:PLTServerSettingsTableSectionAuto];
    return (UISwitch *)[[self.tableView cellForRowAtIndexPath:path] accessoryView];
}

#pragma mark - Private

- (void)switchCell:(UISwitch *)sender
{
	[self saveToDefaults];
	
	if (sender == [self autoConnectSwitch]) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:PLTServerSettingsTableAutoRowRegister
											   inSection:PLTServerSettingsTableSectionAuto];
		[self.tableView beginUpdates];
		if (sender.on) {
			[self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
		}
		else {
			[self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
			[DEFAULTS setBool:NO forKey:PLTDefaultsKeyContextServerAutoRegister];
		}
		[self.tableView endUpdates];
	}
}

- (void)saveToDefaults
{
    [DEFAULTS setObject:self.addressTextField.text forKey:PLTDefaultsKeyContextServerAddress];
    [DEFAULTS setObject:self.portTextField.text forKey:PLTDefaultsKeyContextServerPort];
    [DEFAULTS setObject:@(self.secureSwitch.on) forKey:PLTDefaultsKeyContextServerSecureSockets];
    [DEFAULTS setObject:self.usernameTextField.text forKey:PLTDefaultsKeyContextServerUsername];
    [DEFAULTS setObject:self.passwordTextField.text forKey:PLTDefaultsKeyContextServerPassword];
	[DEFAULTS setObject:@(self.autoConnectSwitch.on) forKey:PLTDefaultsKeyContextServerAutoConnect];
	[DEFAULTS setObject:@(self.autoRegisterSwitch.on) forKey:PLTDefaultsKeyContextServerAutoRegister];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case PLTServerSettingsTableSectionConnectivity:
            return 3;
            break;
        case PLTServerSettingsTableSectionCredentials:
			return 2;
			break;
		case PLTServerSettingsTableSectionAuto: {
			return ([DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoConnect] ? 2 : 1);
			break; }
        default:
			break;
    }
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView textFieldCell];
    UITextField *textField = (UITextField *)cell.accessoryView;
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    textField.delegate = self;
    
    switch (indexPath.section) {
            
        case PLTServerSettingsTableSectionConnectivity: {
            switch (indexPath.row) {
                case PLTServerSettingsTableConnectivityRowAddress:
					textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                    cell.textLabel.text = @"Address";
                    textField.placeholder = @"address";
                    textField.text = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerAddress];
                    textField.keyboardType = UIKeyboardTypeDecimalPad;
                    break;
                case PLTServerSettingsTableConnectivityRowPort:
					textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                    cell.textLabel.text = @"Port";
                    textField.placeholder = @"port";
                    textField.text = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPort];
                    textField.keyboardType = UIKeyboardTypeDecimalPad;
                    break;
                case PLTServerSettingsTableConnectivityRowSecure: {
                    SwitchTableViewCell *switchCell = [tableView switchCell];
                    cell = switchCell;
                    cell.textLabel.text = @"Secure";
                    switchCell.target = self;
                    switchCell.action = @selector(switchCell:);
                    switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyContextServerSecureSockets];
                    break; }
                default:
                    break;
            }
            break; }
            
        case PLTServerSettingsTableSectionCredentials: {
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
			textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            switch (indexPath.row) {
                case PLTServerSettingsTableCredentialsRowUsername:
                    cell.textLabel.text = @"Username";
                    textField.placeholder = @"username";
					textField.text = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerUsername];
                    break;
                case PLTServerSettingsTableCredentialsRowPassword:
                    cell.textLabel.text = @"Password";
                    textField.placeholder = @"password";
                    textField.autocorrectionType = UITextAutocapitalizationTypeNone;
                    textField.text = [DEFAULTS objectForKey:PLTDefaultsKeyContextServerPassword];
                    textField.secureTextEntry = YES;
                    break;
                default:
                    break;
            }
            break; }
			
		case PLTServerSettingsTableSectionAuto: {
			switch (indexPath.row) {
                case PLTServerSettingsTableAutoRowConnect: {
                    SwitchTableViewCell *switchCell = [tableView switchCell];
                    cell = switchCell;
                    cell.textLabel.text = @"Auto-Connect";
                    switchCell.target = self;
                    switchCell.action = @selector(switchCell:);
                    switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoConnect];
                    break; }
				case PLTServerSettingsTableAutoRowRegister: {
                    SwitchTableViewCell *switchCell = [tableView switchCell];
                    cell = switchCell;
                    cell.textLabel.text = @"Auto-Register";
                    switchCell.target = self;
                    switchCell.action = @selector(switchCell:);
                    switchCell.on = [DEFAULTS boolForKey:PLTDefaultsKeyContextServerAutoRegister];
                    break; }
                default:
                    break;
            }
		}
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int64_t delayInSeconds = .05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self saveToDefaults];
    });
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ServerSettingsViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Server Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
