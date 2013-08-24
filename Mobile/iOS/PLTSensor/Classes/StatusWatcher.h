//
//  StatusWatcher.h
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/3/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatusWatcher : NSObject

+ (StatusWatcher *)sharedWatcher;
- (void)setActiveNavigationBar:(UINavigationBar *)aBar animated:(BOOL)animated;
- (void)setActiveNavigationBar:(UINavigationBar *)aBar animated:(BOOL)animated delayed:(BOOL)delayed;

@end
