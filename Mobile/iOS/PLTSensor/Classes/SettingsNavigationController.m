//
//  SettingsNavigationController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/5/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SettingsNavigationController.h"
#import "PLTContextServer.h"


@interface SettingsNavigationController ()

@end


@implementation SettingsNavigationController

#pragma mark - Public

- (CGSize)contentSizeForViewInPopover
{
	//CGFloat contentHeight = 808.0 + 26.0; // w/ settings
	CGFloat contentHeight = 782.0;
	
	//if ([[PLTContextServer sharedContextServer] state] >= PLT_CONTEXT_SERVER_AUTHENTICATED) {
		contentHeight += 18; // additional height for "conected" cell
//	}
	return CGSizeMake(320.0, contentHeight);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
