//
//  PLTDLog.h
//  PLTDevice
//
//  Created by Morgan Davis on 8/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	DLogLevelTrace,
	DLogLevelDebug,
	DLogLevelInfo,
	DLogLevelWarn,
	DLogLevelError
} DLogLevel;

extern DLogLevel _pltDLogLevel;// = DLogLevelError;

void DLog(DLogLevel level, NSString *format, ...);
