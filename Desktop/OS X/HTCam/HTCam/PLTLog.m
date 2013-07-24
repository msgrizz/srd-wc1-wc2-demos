//
//  PLTLog.m
//
//  Created by Davis, Morgan on 1/22/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#import "PLTLog.h"


FILE    *file;

NSString *getLogPath()
{
	NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
	NSString *logsPath = [libraryPath stringByAppendingPathComponent:@"Logs"];
	NSString *logPath = [logsPath stringByAppendingPathComponent:@"HTCam.log"];
    return logPath;
}

void checkFile()
{
    NSString *filepath = getLogPath();
    
    // open the file is necessary
    if (!file) {
        const char *filepathCStr = [filepath UTF8String];
        file = fopen(filepathCStr,"a");
        if( file==NULL ) {
            NSLog(@"fopen() error %d: %s",errno,strerror(errno));
        }
    }
}

void _dlog(NSString *output)
{
    NSLog(@"%@",output);
}

void _flog(NSString *output)
{
    checkFile();
    if (file) {
        char tmpTime[28];
        time_t timeStr;
        timeStr = time(0);
        strftime(tmpTime, 28,"%Y-%m-%d-%H:%M:%S",localtime(&timeStr));
        NSString *message = [NSString stringWithFormat:@"%s\t%@\n",tmpTime,output];
        
        static bool firstLog = YES;
        if (firstLog) {
            fprintf(file,"\n\n-------------------------\n");
            firstLog = NO;
        }
        
        const char *fileStr = [message UTF8String];
        fprintf(file,fileStr);
        fflush(file);
    }
}

NSString *getLogString(NSString *format, NSString *file, int line, va_list list)
{
    NSString *flFormat = format;
    NSString *fileLine = @"";
    if (file) {
        fileLine = [NSString stringWithFormat:@"%@:%d: ",[file lastPathComponent],line];
    }
    flFormat = [fileLine stringByAppendingString:format];
    NSString *formatted = [[[NSString alloc] initWithFormat:flFormat arguments:list] autorelease];
    return formatted;
}

void _PLTDLog( const char *aFile, int aLine, NSString *format, ... )
{
    va_list list;
	va_start(list, format);

    NSString *message = getLogString(format, [NSString stringWithUTF8String:aFile], aLine, list);
    
	va_end(list);
    
    _dlog(message);
}

void _PLTFLog( const char *aFile, int aLine, NSString *format, ... )
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // needed to wrap getLogString if ARC is on, since an NSAutoreleasePool may not be present
    
    va_list list;
	va_start(list, format);
    
    NSString *fMessage = getLogString(format, nil, 0, list);
    NSString *dMessage = getLogString(format, [NSString stringWithUTF8String:aFile], aLine, list);
    
	va_end(list);
    
    _flog(fMessage);
    _dlog(dMessage);
    
    [pool release];
}
