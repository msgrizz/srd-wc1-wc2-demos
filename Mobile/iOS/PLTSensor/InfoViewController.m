//
//  InfoViewController.m
//  CSR Wireless Sensor
//
//  Created by Doug Rosener on 9/17/12.
//  Copyright (c) 2012 Cambridge Silicon Radio. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
@synthesize consoleTextView = _consoleTextView;
@synthesize serverTextView ;
@synthesize portTextView;
@synthesize userTextView;
@synthesize passTextView;
@synthesize switchView;

-(IBAction)doneButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField==serverTextView)
    {
        self.consoleTextView.text=textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}
@end
