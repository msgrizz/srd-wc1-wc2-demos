//
//  NSProcessInfo+Debugging.h
//  PLTSensor
//
//  Created by Davis, Morgan on 4/15/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSProcessInfo (Debugging)

- (BOOL)isRunningInDebugger;

@end
