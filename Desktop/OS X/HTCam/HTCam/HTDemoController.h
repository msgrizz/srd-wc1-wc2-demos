//
//  HTDemoController.h
//  HTCam
//
//  Created by Davis, Morgan on 7/17/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	HTCamNone = 0,
	HTCam1 = 1,
	HTCam2 = 2,
	HTCam3 = 3,
	//HTCamAux = 4 // 4th port on video switch
} HTCam;


@protocol HTDemoControllerDelegate;

@interface HTDemoController : NSObject

+ (HTDemoController *)sharedController;
- (void)startDemo;
- (void)stopDemo;

@property (nonatomic, assign) id <HTDemoControllerDelegate> delegate;
@property (nonatomic, readonly) NSDictionary *latestHeadsetInfo;
@property (nonatomic, assign) BOOL isStarted;

@end


@protocol HTDemoControllerDelegate <NSObject>

- (void)HTDemoControllerDidStart:(HTDemoController *)controller;
- (void)HTDemoControllerDidStop:(HTDemoController *)controller;
- (void)HTDemoController:(HTDemoController *)controller changedActiveCam:(HTCam)cam;

@end
