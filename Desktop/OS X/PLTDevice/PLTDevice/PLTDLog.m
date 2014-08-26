//
//  PLTDLog.m
//  PLTDevice
//
//  Created by Morgan Davis on 8/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTDLog.h"


DLogLevel _pltDLogLevel = DLogLevelWarn;

void DLog(DLogLevel level, NSString *format, ...)
{
	if (level >= _pltDLogLevel) {
		va_list args;
		va_start(args, format);
		NSLogv(format, args);
		va_end(args);
	}
}
