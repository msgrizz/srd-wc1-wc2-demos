//
//  SettingsPacketDataViewController.m
//  WC2 Kit
//
//  Created by Morgan Davis on 12/31/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "SettingsPacketDataViewController.h"
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import "PLTDevice_Internal.h"
#import "BRDeviceUtilities.h"


@interface SettingsPacketDataViewController ()

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)deviceDidCloseConnectionNotification:(NSNotification *)note;
- (void)deviceWillSendDataNotification:(NSNotification *)note;
- (void)deviceDidReceiveDataNotification:(NSNotification *)note;
- (void)scrollLog;

@end


@implementation SettingsPacketDataViewController

#pragma mark - Private

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	
}

- (void)deviceDidCloseConnectionNotification:(NSNotification *)note
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deviceWillSendDataNotification:(NSNotification *)note
{
	NSData *data = (NSData *)note.userInfo[PLTDeviceDataNotificationKey];
	//NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSString *hexString = BRDeviceHexStringFromData(data, 2);
	UITextView *tv = (UITextView *)self.view;
	tv.text = [NSString stringWithFormat:@"%@\n--> %@", tv.text, hexString];
	[self scrollLog];
}

- (void)deviceDidReceiveDataNotification:(NSNotification *)note
{
	NSData *data = (NSData *)note.userInfo[PLTDeviceDataNotificationKey];
	//NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSString *hexString = BRDeviceHexStringFromData(data, 2);
	UITextView *tv = (UITextView *)self.view;
	tv.text = [NSString stringWithFormat:@"%@\n<-- %@", tv.text, hexString];
	[self scrollLog];
}

- (void)scrollLog
{
	UITextView *tv = (UITextView *)self.view;
	if ([tv.text length] >= 10000) {
		tv.text = [tv.text substringFromIndex:1000];
	}
	
	[tv scrollRangeToVisible:NSMakeRange([tv.text length], 0)];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nil bundle:nil];
	self.title = @"Packet Data";
	UITextView *tv = [[UITextView alloc] initWithFrame:CGRectZero];
	tv.font = [UIFont fontWithName:@"Menlo" size:10];
	self.view = tv;
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidCloseConnectionNotification:) name:PLTDeviceDidCloseConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceWillSendDataNotification:) name:PLTDeviceWillSendDataNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidReceiveDataNotification:) name:PLTDeviceDidReceiveDataNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc removeObserver:self name:PLTDeviceDidCloseConnectionNotification object:nil];
	[nc removeObserver:self name:PLTDeviceWillSendDataNotification object:nil];
	[nc removeObserver:self name:PLTDeviceDidReceiveDataNotification object:nil];
}

@end
