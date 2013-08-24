//
//  AddLocationViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/29/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "AddLocationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "LocationMonitor.h"
#import "UITableView+Cells.h"


@interface AddLocationViewController () //<UITextFieldDelegate>

- (BOOL)inputIsValid;

@property(nonatomic,readonly)   UITextField     *labelTextField;
@property(nonatomic,readonly)   UITextField     *latTextField;
@property(nonatomic,readonly)   UITextField     *lngTextField;

@end


@implementation AddLocationViewController

@dynamic labelTextField;
- (UITextField *)labelTextField
{
    return (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] accessoryView];
}

@dynamic latTextField;
- (UITextField *)latTextField
{
    return (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] accessoryView];
}

@dynamic lngTextField;
- (UITextField *)lngTextField
{
    return (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] accessoryView];
}

#pragma mark - Public

- (IBAction)doneButton:(id)sender
{
    if ([self inputIsValid]) {
        //CLLocationCoordinate2DIsValid
        CLLocationCoordinate2D coord = { [self.latTextField.text doubleValue] , [self.lngTextField.text doubleValue] };
        if (CLLocationCoordinate2DIsValid(coord)) {
            NSDictionary *location = @{
            PLTDefaultsKeyOverrideLocationLabel : self.labelTextField.text,
            PLTDefaultsKeyOverrideLocationLatitude : self.latTextField.text,
            PLTDefaultsKeyOverrideLocationLongitude : self.lngTextField.text };
            
            [self.delegate addLocationViewController:self didAddLocation:location];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Location" message:@"Please enter a valid latitude and longitude."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Entry" message:@"Please enter a label, latitude, and longitude."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelButton:(id)sender
{
    [self.delegate addLocationViewControllerDidCancel:self];
}

#pragma mark - Private

- (BOOL)inputIsValid
{
	return ((self.labelTextField.text.length && self.latTextField.text.length && self.lngTextField.text.length) ? YES : NO);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
		default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView textFieldCell];
    
//    cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"TextFieldCell"];
//    }
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 210, 39)];
//    textField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    textField.borderStyle = UITextBorderStyleNone;
//    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    textField.autoresizesSubviews = YES;
//    //textField.delegate = self;
//    cell.accessoryView = textField;
    
    switch (indexPath.section) {
        case 0: {
            UITextField *textField = (UITextField *)cell.accessoryView;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Name";
                    textField.placeholder = @"name";
                    textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                case 1:
                    cell.textLabel.text = @"Latitude";
                    textField.placeholder = @"latitude";
                    textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                case 2:
                    cell.textLabel.text = @"Longitude";
                    textField.placeholder = @"longitude";
                    textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                default:
                    break;
            }
            break; }
        case 1: {
            cell = [tableView buttonCell];
            cell.textLabel.text = @"Use Current Location";
            break; }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section) {
        LocationMonitor *monitor = [LocationMonitor sharedMonitor];
        self.labelTextField.text = monitor.realPlacemark.name;
        CLLocationCoordinate2D coordinate = monitor.realLocation.coordinate;
        self.latTextField.text = [NSString stringWithFormat:@"%f",coordinate.latitude];
        self.lngTextField.text = [NSString stringWithFormat:@"%f",coordinate.longitude];
    }
}

//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
//{
//    NSLog(@"textField: %@ shouldChangeCharactersInRange: %@ replacementString: %@", textField, NSStringFromRange(range), string);
//    int64_t delayInSeconds = .01;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self inputIsValid];
//    });
//    return YES;
//}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"AddLocationViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"New Location";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationItem.hidesBackButton = YES;
	
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton:)];
	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton:)];
	[self.navigationItem setLeftBarButtonItem:cancelItem];
	[self.navigationItem setRightBarButtonItem:doneItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.doneButton.enabled = NO;
}

@end
