//
//  MainWindowController.h
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString *const PLTHTCamNotificationLogMessage;
extern NSString *const PLTHTCamNotificationKeyLogMessage;


@interface MainWindowController : NSWindowController

- (void)log:(NSString *)text, ...;
- (IBAction)startStopButton:(id)sender;
- (IBAction)settingsButton:(id)sender;

@property (nonatomic, retain) IBOutlet NSToolbarItem *startStopToolbarItem;
@property (nonatomic, retain) IBOutlet NSImageView *cam1ImageView;
@property (nonatomic, retain) IBOutlet NSImageView *cam2ImageView;
@property (nonatomic, retain) IBOutlet NSImageView *cam3ImageView;
@property (nonatomic, retain) IBOutlet NSTextView *logTextView;

@end
