//
//  MainWindowController.h
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController_IPCams : NSWindowController

- (IBAction)connectDisconnectButton:(id)sender;
- (IBAction)fullscreenButton:(id)sender;
- (IBAction)settingsButton:(id)sender;

@property (nonatomic, retain) IBOutlet NSImageView *activeImageView;
@property (nonatomic, retain) IBOutlet NSImageView *cam1ImageView;
@property (nonatomic, retain) IBOutlet NSImageView *cam2ImageView;
@property (nonatomic, retain) IBOutlet NSImageView *cam3ImageView;
@property (nonatomic, retain) IBOutlet NSTextField *activeCamFPSTextField;
@property (nonatomic, retain) IBOutlet NSTextField *cam1FPSTextField;
@property (nonatomic, retain) IBOutlet NSTextField *cam2FPSTextField;
@property (nonatomic, retain) IBOutlet NSTextField *cam3FPSTextField;
@property (nonatomic, retain) IBOutlet NSToolbarItem *connectDisconnectToolbarItem;
@property (nonatomic, retain) IBOutlet NSToolbarItem *fullscreenToolbarItem;
@property (nonatomic, retain) IBOutlet NSToolbarItem *settingsToolbarItem;

@end
