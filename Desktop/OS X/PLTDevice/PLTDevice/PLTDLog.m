//
//  PLTDLog.m
//  PLTDevice
//
//  Created by Morgan Davis on 8/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTDLog.h"


@interface PLTDLogger()

- (void)log:(DLogLevel)level message:(NSString *)message;

@end


@implementation PLTDLogger

#pragma mark - Public

+ (PLTDLogger *)sharedLogger
{
	static PLTDLogger *logger = nil;
	if (!logger) {
		logger = [[PLTDLogger alloc] init];
		logger.level = DLogLevelWarn;
	}
	return logger;
}

- (void)log:(DLogLevel)level message:(NSString *)message
{
	@synchronized(self) {
		if (level >= self.level) {
			NSLog(@"%@", message);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.plantronics.dlog" object:nil userInfo:@{@"level": @(level), @"message": message}];
		}
	}
}

@end


static NSLock *lock;

void DLog(DLogLevel level, NSString *format, ...)
{
	if (!lock) lock = [[NSLock alloc] init];
	[lock lock];
	va_list args;
	va_start(args, format);
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
	[[PLTDLogger sharedLogger] log:level message:message];
	va_end(args);
	[lock unlock];
}
