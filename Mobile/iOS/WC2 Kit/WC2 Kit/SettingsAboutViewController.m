//
//  SettingsAboutViewController.m
//  WC2 Kit
//
//  Created by Morgan Davis on 12/31/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "SettingsAboutViewController.h"
#import "UITableView+Cells.h"
#import "PLTDeviceHelper.h"
#import "PLTDevice.h"
#import "SettingsPacketDataViewController.h"


typedef enum {
	SettingsAboutSectionApp,
	SettingsAboutSectionHeadset
} SettingsAboutSection;

typedef enum {
	SettingsAboutSectionAppRowVersion
} SettingsAboutSectionAppRow;

typedef enum {
	SettingsAboutSectionHeadsetRowModel,
	SettingsAboutSectionHeadsetRowFWVersion,
	SettingsAboutSectionHeadsetRowPacketData
} SettingsAboutSectionHeadsetRow;


@interface SettingsAboutViewController ()

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)deviceDidCloseConnectionNotification:(NSNotification *)note;

@end


@implementation SettingsAboutViewController

#pragma mark - Private

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self.tableView reloadData];
}

- (void)deviceDidCloseConnectionNotification:(NSNotification *)note
{
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (HEADSET_CONNECTED) return 2;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case SettingsAboutSectionApp: return 1;
		case SettingsAboutSectionHeadset: return 3;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView value1Cell];
	
	switch (indexPath.section) {
		case SettingsAboutSectionApp:
			cell.textLabel.text = @"Version";
			cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
			break;
		case SettingsAboutSectionHeadset: {
			if (HEADSET_CONNECTED) {
				switch (indexPath.row) {
					case SettingsAboutSectionHeadsetRowModel: {
						cell.textLabel.text = @"Model";
						cell.detailTextLabel.text = CONNECTED_DEVICE.model;
						break; }
					case SettingsAboutSectionHeadsetRowFWVersion: {
						cell.textLabel.text = @"FW Version";
						cell.detailTextLabel.text = CONNECTED_DEVICE.firmwareVersion;
						break; }
					case SettingsAboutSectionHeadsetRowPacketData: {
						cell = [tableView value1Cell];
						cell.textLabel.text = @"Packet Data";
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						cell.textLabel.textAlignment = NSTextAlignmentLeft;
						cell.detailTextLabel.text = @"";
						break; }
				}
			}
			break; }
	}
	return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case SettingsAboutSectionApp: return @"app";
		case SettingsAboutSectionHeadset: return @"headset";
	}
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==SettingsAboutSectionHeadset && indexPath.row==SettingsAboutSectionHeadsetRowPacketData) {
		return YES;
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.navigationController pushViewController:[[SettingsPacketDataViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
}

#pragma mark - UIViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	self.title = @"About";
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidCloseConnectionNotification:) name:PLTDeviceDidCloseConnectionNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc removeObserver:self name:PLTDeviceDidCloseConnectionNotification object:nil];
}

@end
