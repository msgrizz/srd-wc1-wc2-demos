//
//  RTSPStreamReader.h
//  HTCam
//
//  Created by Davis, Morgan on 7/11/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RTSPStreamReaderDelegate;


@interface RTSPStreamReader : NSObject

//+ (RTSPStreamReader *)sharedStreamReader;
- (void)openStreamAtURL:(NSURL *)url;
- (BOOL)openStreamsAtURLs:(NSArray *)urls;

@property(nonatomic, assign) id <RTSPStreamReaderDelegate> delegate;

@end


@protocol RTSPStreamReaderDelegate <NSObject>

- (void)RTSPStreamReader:(RTSPStreamReader *)streamReader didGetNewFrame:(NSImage *)frame forURL:(NSURL *)url;

@end
