//
//  ServerLogViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ServerLogViewController.h"
#import "PLTContextServer.h"


@interface ServerLogViewController ()

@end


@implementation ServerLogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Log";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.logTextView.text = [PLTContextServer sharedContextServer].log;
	[self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length, 0)];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:PLTContextServerNewLogOutputNotification object:nil
													   queue:nil usingBlock:^(NSNotification *note) {
														   NSString *output = note.userInfo[PLTContextServerNewLogOutputNotificationInfoKeyOutput];
														   self.logTextView.text = [self.logTextView.text stringByAppendingString:output];
														   [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length, 0)];
													   }];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTContextServerNewLogOutputNotification object:nil];
}

@end
