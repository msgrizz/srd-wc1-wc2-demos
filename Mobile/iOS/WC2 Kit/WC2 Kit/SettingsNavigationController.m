//
//  SettingsNavigationController.m
//  PLTSensor
//
//  Created by Davis, Morgan on 4/5/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "SettingsNavigationController.h"


@interface SettingsNavigationController ()

@end


@implementation SettingsNavigationController

#pragma mark - Public

- (CGSize)contentSizeForViewInPopover
{
	//CGFloat contentHeight = 782.0;
	CGFloat contentHeight = 840.0;
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

@end
