//
//  VideoSwitchController
//  HTCam
//
//  Created by Davis, Morgan on 7/17/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTDemoController.h"


@interface VideoSwitchController : NSObject

+ (VideoSwitchController *)sharedController;
- (void)openConnection;
- (void)closeConnection;
- (void)activateCam:(HTCam)camID;

@property (nonatomic, assign) BOOL isConncetionOpen;

@end
