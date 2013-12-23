//
//  MissileWindowController.m
//  MissileDodger
//
//  Created by Davis, Morgan on 11/16/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "MissileWindowController.h"
#import <AVFoundation/AVFoundation.h>


@interface MissileWindowController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    CMSampleBufferRef lastFrameBuffer;
}

- (void)startAVCapture;
- (void)stopAVCapture;

@property(nonatomic, retain) AVCaptureDevice                *captureDevice;
@property(nonatomic, retain) AVCaptureSession               *avSession;
@property(nonatomic, retain) AVCaptureVideoPreviewLayer     *previewLayer;
@property(nonatomic, retain) AVCaptureVideoDataOutput       *videoDataOutput;
@property(nonatomic, retain) dispatch_queue_t               videoDataOutputQueue;
@property(nonatomic, assign) CMSampleBufferRef              lastFrameBuffer;
@property(nonatomic, retain) NSLock                         *captureFrameLock;

@property(nonatomic, retain) CIDetector                     *faceDetector;
@property(atomic, retain)    CIFaceFeature                  *latestFace;
@property(nonatomic, retain) NSImageView                    *faceOverlayView;
@property(nonatomic, retain) NSLock                         *processFrameLock;

@end


@implementation MissileWindowController

#pragma mark - Private

- (void)startAVCapture
{
	NSLog(@"startAVCapture");
	
	self.avSession = [[AVCaptureSession alloc] init];
	[self.avSession beginConfiguration];
	[self.avSession setSessionPreset:AVCaptureSessionPreset1280x720];
	
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.avSession];
	[self.previewLayer setBackgroundColor:[[NSColor blackColor] CGColor]];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.window.contentView setWantsLayer:YES];
    ((NSView *)(self.window.contentView)).layer = self.previewLayer;
	self.previewLayer.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
	
	NSError *err = nil;
	self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&err];
	if (err) NSLog(@"Error: %@", err);

	if ([self.avSession canAddInput:deviceInput]) [self.avSession addInput:deviceInput];
    
	self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
	// both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
									   nil];
	[self.videoDataOutput setVideoSettings:rgbOutputSettings];
	[self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
	self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
	if ([self.avSession canAddOutput:self.videoDataOutput]) [self.avSession addOutput:self.videoDataOutput];
    
	[self.avSession commitConfiguration];
	[self.avSession startRunning];
}

- (void)stopAVCapture
{
	[self.avSession stopRunning];
	self.avSession = nil;
	self.videoDataOutput = nil;
	[self.previewLayer removeFromSuperlayer];
	self.previewLayer = nil;
}

- (void)processLatestFrame
{
	@synchronized(self.processFrameLock) {
		
    CMSampleBufferRef sampleBuffer;
			[frameLock lock];
			sampleBuffer = self.lastFrameBuffer;
			if( !sampleBuffer ) {
				AOLogL(AODebugLogLevel,@"No frame buffer. Waiting...");
				[pool release];
				[frameLock unlock];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .25 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
					[self performSelectorInBackground:@selector(processLatestFrame) withObject:nil];
					//[self processLatestFrame];
				});
				return;
			}
			CFRetain(sampleBuffer);
			
			// NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
			CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
			CIImage *ciImage = [[[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)attachments] autorelease];
			CFRelease(sampleBuffer);
			[frameLock unlock];
			
			//	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
			//	CVPixelBufferRelease( pixelBuffer );
			if( attachments ) CFRelease(attachments);
			UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
			EXIF_ORIENTATION orientation;
			
			/* kCGImagePropertyOrientation values
			 The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
			 by the TIFF and EXIF specifications -- see enumeration of integer constants. 
			 The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
			 
			 used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
			 If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
			
			switch (curDeviceOrientation) {
				case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
					orientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
					break;
				case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
					orientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
					break;
				case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
					orientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
					break;
				case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
				default:
					orientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
					break;
			}
			
			[self processPreviewFrame:ciImage];
}

- (void)processFrame:(CIImage *)frame
{
    
}

- (void)featureFound:(CIFeature *)feature inFrame:(CIImage *)frame
{
    
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	[self.captureFrameLock lock];
	CFRetain(sampleBuffer);
	if( lastFrameBuffer ) {
		CFRelease(lastFrameBuffer);
		lastFrameBuffer = nil;
	}
	self.lastFrameBuffer = sampleBuffer;
	[self.captureFrameLock unlock];
}

#pragma mark - NSWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    return self;
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];
    [self startAVCapture];
    [self performSelectorInBackground:@selector(processLatestFrame) withObject:nil];
}

//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//	self.statusLabel.layer.bounds = self.statusLabel.bounds;
//	[self.view.layer addSublayer:statusLabel.layer];
//	self.activityIndicator.layer.bounds = self.activityIndicator.bounds;
//	[self.view.layer addSublayer:activityIndicator.layer];
//}

//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//	[self.navigationController setToolbarHidden:YES animated:YES];
//	[self.navigationItem setHidesBackButton:NO animated:NO];
//	[self.flashView removeFromSuperview];
//	self.activityIndicator.hidden = YES;
//	self.capturePreviewImageView.hidden = YES;
//	self.awaitingCapture = NO;
//	[self startAVCapture];
//}

//- (void)viewDidDisappear:(BOOL)animated
//{
//	[super viewDidDisappear:animated];
//	[self stopAVCapture];
//}

//- (void)dealloc
//{	
//	[captureDevice release];
//    [avSession release];
//	[previewView release];
//	[previewLayer release];
//	[stillImageOutput release];
//	[videoDataOutput release];
//	[statusLabel release];
//	[activityIndicator release];
//	[capturePreviewImageView release];
//	if( videoDataOutputQueue ) {
//		dispatch_release(videoDataOutputQueue);
//		videoDataOutputQueue = nil;
//	}
//	if( lastFrameBuffer != NULL ) {
//		CFRelease(lastFrameBuffer);
//		lastFrameBuffer = nil;
//	}
//	[flashView release];
//	[super dealloc];
//}

@end
