//
//  StreamController.m
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "CamStreamController.h"
#import "RTSPStreamReader.h"


#define FRAMERATE_AVERAGE_TIME	2.0


@interface CamStreamController () <RTSPStreamReaderDelegate>

- (void)frameCountTimerFired:(NSTimer *)aTimer;

@property (nonatomic, retain) NSMutableDictionary *streams; // stream IDs keyed by URL
@property (nonatomic, retain) NSMutableDictionary *frameCounts; // frameCounts in the past FRAMERATE_AVERAGE_TIME seconds keyed by ID
@property (nonatomic, retain) NSTimer *frameCountTimer;
@property (nonatomic, retain) NSMutableDictionary *framerates; // framerates keyed by ID

@end


@implementation CamStreamController

#pragma mark - Public

+ (CamStreamController *)sharedController
{
	static CamStreamController *controller = nil;
	if (!controller) controller = [[CamStreamController alloc] init];
	return controller;
}

- (void)openStreamsWithIDs:(NSArray *)ids atURLs:(NSArray *)urls
{
	NSLog(@"openStreamsWithIDs: %@ atURLs: %@", ids, urls);
	
	for (int i = 0; i<[urls count]; i++) {
		NSURL *url = urls[i];
		NSNumber *theID = ids[i];
		self.streams[url] = theID;
		self.frameCounts[theID] = @(0.0);
		
		
		RTSPStreamReader *streamer = [[RTSPStreamReader alloc] init];
		streamer.delegate = self;
		//[streamer openStreamAtURL:url];
		[streamer performSelectorInBackground:@selector(openStreamAtURL:) withObject:url];
	}
	
//	RTSPStreamReader *streamer = [RTSPStreamReader sharedStreamReader];
//	streamer.delegate = self;
//	//[streamer openStreamsAtURLs:urls];
//	[streamer performSelectorInBackground:@selector(openStreamsAtURLs:) withObject:urls];
	
	if ([self.frameCountTimer isValid]) {
		[self.frameCountTimer invalidate];
	}
	//self.frameCountTimer = [NSTimer scheduledTimerWithTimeInterval:FRAMERATE_AVERAGE_TIME target:self selector:@selector(frameCountTimerFired:) userInfo:nil repeats:YES];
}

//- (void)closeStreamWithID:(NSUInteger)theID
//{
//	NSLog(@"closeStreamWithID: %ld", theID);
//}

- (float)framerateForCameraWithID:(NSInteger)camID
{
	@synchronized(self.frameCounts) {
		return [self.framerates[@(camID)] floatValue];
	}
}

#pragma mark - Private

- (void)frameCountTimerFired:(NSTimer *)aTimer
{
	@synchronized(self.frameCounts) {
		for (NSNumber *camID in self.frameCounts) {
			NSNumber *frameCount = self.frameCounts[camID];
			if (!frameCount) frameCount = @(0);
			float fps = [frameCount floatValue] / FRAMERATE_AVERAGE_TIME;
			self.framerates[camID] = @(fps);
			self.frameCounts[camID] = @(0.0);
		}
	}
}

#pragma mark - RTSPStreamReaderDelegate

- (void)RTSPStreamReader:(RTSPStreamReader *)streamReader didGetNewFrame:(NSImage *)frame forURL:(NSURL *)url
{
	NSLog(@"RTSPStreamReader:didGetNewFrame: %@ forURL: %@ (ID: %@)", frame, url, self.streams[url]);
	
	NSNumber *camID = self.streams[url];
	
	@synchronized(self.frameCounts) {
		// update frame count for framerate timer
		NSNumber *oldFrameCount = self.frameCounts[camID];
		if (!oldFrameCount) oldFrameCount = @(0);
		self.frameCounts[camID] = @([oldFrameCount integerValue] + 1);
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"dickle" object:nil userInfo:@{@"frame": frame, @"id": camID}];
}

#pragma mark - NSObject

- (id)init
{
	self = [super init];
	self.streams = [NSMutableDictionary dictionary];
	self.frameCounts = [NSMutableDictionary dictionary];
	self.framerates = [NSMutableDictionary dictionary];
	return self;
}

@end
