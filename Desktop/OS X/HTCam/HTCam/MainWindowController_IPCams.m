//
//  MainWindowController.m
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "MainWindowController_IPCams.h"
#import "HTCamController.h"
#import "SettingsWindowController.h"
#import "HTCamController.h"
#import "CamStreamController.h"


@interface MainWindowController_IPCams () <HTCamControllerDelegate>

- (void)updateActiveCamFPS:(float)fps;
- (void)updateCam1FPS:(float)fps;
- (void)updateCam2FPS:(float)fps;
- (void)updateCam3FPS:(float)fps;
- (void)framerateTimerFired:(NSTimer *)aTimer;

@property (nonatomic, retain) SettingsWindowController *settingsWindowController;
@property (nonatomic, retain) NSDictionary *fpsTextViewAttributes;
@property (nonatomic, retain) NSTimer *framerateTimer;

@end


@implementation MainWindowController_IPCams

#pragma mark - Private

- (void)updateActiveCamFPS:(float)fps
{
	NSString *fpsString = [NSString stringWithFormat:@"%.1f fps", fps];
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:fpsString attributes:self.fpsTextViewAttributes];
	[attrString setAlignment:NSRightTextAlignment range:NSMakeRange(0, [attrString length])];
	[self.activeCamFPSTextField setAttributedStringValue:attrString];
}

- (void)updateCam1FPS:(float)fps
{
	NSString *fpsString = [NSString stringWithFormat:@"%.1f fps", fps];
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:fpsString attributes:self.fpsTextViewAttributes];
	[attrString setAlignment:NSRightTextAlignment range:NSMakeRange(0, [attrString length])];
	[self.cam1FPSTextField setAttributedStringValue:attrString];
}

- (void)updateCam2FPS:(float)fps
{
	NSString *fpsString = [NSString stringWithFormat:@"%.1f fps", fps];
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:fpsString attributes:self.fpsTextViewAttributes];
	[attrString setAlignment:NSRightTextAlignment range:NSMakeRange(0, [attrString length])];
	[self.cam2FPSTextField setAttributedStringValue:attrString];
}

- (void)updateCam3FPS:(float)fps
{
	NSString *fpsString = [NSString stringWithFormat:@"%.1f fps", fps];
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:fpsString attributes:self.fpsTextViewAttributes];
	[attrString setAlignment:NSRightTextAlignment range:NSMakeRange(0, [attrString length])];
	[self.cam3FPSTextField setAttributedStringValue:attrString];
}

- (void)framerateTimerFired:(NSTimer *)aTimer
{
	CamStreamController *csc = [CamStreamController sharedController];
	[self updateActiveCamFPS:[csc framerateForCameraWithID:[[HTCamController sharedController] activeCam]]];
//	[self updateCam1FPS:[csc framerateForCameraWithID:HTCam1]];
//	[self updateCam2FPS:[csc framerateForCameraWithID:HTCam2]];
//	[self updateCam3FPS:[csc framerateForCameraWithID:HTCam3]];
}

#pragma mark - IBActions

- (IBAction)connectDisconnectButton:(id)sender
{
	NSLog(@"connectDisconnectButton:");
}

- (IBAction)fullscreenButton:(id)sender
{
	NSLog(@"fullscreenButton:");
}

- (IBAction)settingsButton:(id)sender
{
	NSLog(@"settingsButton:");
	
	if (!self.settingsWindowController) {
		self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:nil];
	}
	
	[self.settingsWindowController showWindow:self];
}

#pragma mark - NSNibAwakening

- (void)awakeFromNib
{
	[[self window] center];
	
	[self updateActiveCamFPS:0.0];
	[self updateCam1FPS:0.0];
	[self updateCam2FPS:0.0];
	[self updateCam3FPS:0.0];
	
	self.framerateTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(framerateTimerFired:) userInfo:nil repeats:YES];
}

#pragma mark - NSObject

- (id)init
{
	self = [super init];
	
	NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = .5;
    shadow.shadowOffset = NSMakeSize(0, -1);
    shadow.shadowColor = [NSColor whiteColor];
	self.fpsTextViewAttributes = @{NSShadowAttributeName: shadow};
	
	[[NSNotificationCenter defaultCenter] addObserverForName:@"dickle" object:nil queue:nil usingBlock:^(NSNotification *note) {
		NSInteger camID = [(NSNumber *)[note userInfo][@"id"] integerValue];
		NSImage *frame = [note userInfo][@"frame"];
//		switch (camID) {
//			case HTCam1:
//				[self.activeImageView setImage:frame];
//				[self.cam1ImageView setImage:frame];
//				break;
//			case HTCam2:
//				[self.cam2ImageView setImage:frame];
//				break;
//			case HTCam3:
//				[self.cam3ImageView setImage:frame];
//				break;
//		}
	}];
	
	return self;
}

@end
