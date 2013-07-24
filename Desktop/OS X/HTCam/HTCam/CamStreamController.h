//
//  StreamController.h
//  HTCam
//
//  Created by Davis, Morgan on 6/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CamStreamControllerDelegate;


@interface CamStreamController : NSObject

+ (CamStreamController *)sharedController;
- (void)openStreamsWithIDs:(NSArray *)ids atURLs:(NSArray *)urls;
//- (void)closeStreamWithID:(NSUInteger)theID;
- (float)framerateForCameraWithID:(NSInteger)camID;

@property(nonatomic, assign) id <CamStreamControllerDelegate> delegate;

@end


@protocol CamStreamControllerDelegate <NSObject>

- (void)CamStreamController:(CamStreamController *)controller didOpenStream:(NSInteger)streamID;
- (void)CamStreamController:(CamStreamController *)controller didCloseStream:(NSInteger)streamID;
- (void)CamStreamController:(CamStreamController *)controller didGetFrame:(NSImage *)frame forCam:(NSUInteger)camID;

@end

