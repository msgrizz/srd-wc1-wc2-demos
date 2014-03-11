//
//  MainWindowController.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MainWindowController.h"
#import "PLTDevice.h"


@interface MainWindowController () <PLTDeviceInfoObserver>

@end


@implementation MainWindowController

#pragma mark - Private

#pragma mark - NSWindowController

- (id)init
{
	if (self = [super initWithWindowNibName:@"MainWindow.xib"]) {
        
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:PLTNewDeviceAvailableNotification object:Nil queue:NULL usingBlock:^(NSNotification *note) {
            NSLog(@"Device available! %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:PLTDidOpenDeviceConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
            NSLog(@"Device conncetion open!!! %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
        }];
        
        NSArray *devices = [PLTDevice availableDevices];
        NSLog(@"availableDevices: %@", devices);
        
        if ([devices count]) {
            PLTDevice *ourDevice = devices[0];
            [ourDevice openConnection];
        }
        
		return self;
	}
	return nil;
}

- (NSString *)windowNibName
{
    return @"MainWindow";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
 }

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
    NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
}

@end
