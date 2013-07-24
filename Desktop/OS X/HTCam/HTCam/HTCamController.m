//
//  HTCamMux.m
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "HTCamController.h"
#import "CamStreamController.h"


const NSString *HTCamControllerDidGetCamFrameNotification =		@"HTCamControllerDidGetCamFrameNotification";
const NSString *HTCamControllerFrameNotificationKey =			@"HTCamControllerFrameNotificationKey";


@interface HTCamController () <CamStreamControllerDelegate>

@end


@implementation HTCamController

#pragma mark - Public

+ (HTCamController *)sharedController
{
	static HTCamController *me = nil;
	if (!me) me = [[HTCamController alloc] init];
	return me;
}

#pragma mark - StreamControllerDelegate

- (void)CamStreamController:(CamStreamController *)controller didOpenStream:(NSInteger)streamID
{
	NSLog(@"streamController:didOpenStream: %ld", streamID);
}

- (void)CamStreamController:(CamStreamController *)controller didCloseStream:(NSInteger)streamID
{
	NSLog(@"streamController:didCloseStream: %ld", streamID);
}

- (void)CamStreamController:(CamStreamController *)controller didGetFrame:(NSImage *)frame forCam:(NSUInteger)camID
{
	NSLog(@"streamController:didGetFrame: %@ forCam: %ld", frame, camID);
}

@end
