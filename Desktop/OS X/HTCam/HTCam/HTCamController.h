//
//  HTCamMux.h
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


extern const NSString *HTCamControllerDidGetCamFrameNotification;
extern const NSString *HTCamControllerFrameNotificationKey;


//typedef enum {
//	HTCam1 = 1,
//	HTCam2 = 2,
//	HTCam3 = 3
//} HTCam;


@interface HTCamController : NSObject

+ (HTCamController *)sharedController;

@property (nonatomic, readonly) NSUInteger activeCam;

@end


@protocol HTCamControllerDelegate <NSObject>

- (void)HTCamController:(HTCamController *)controller didGetFrame:(NSImage *)frame forCam:(NSInteger)camID;
- (void)HTCamController:(HTCamController *)controller maySwitchActiveCam:(NSInteger)camID;
- (void)HTCamController:(HTCamController *)controller didSwitchActiveCam:(NSInteger)camID;

@end
