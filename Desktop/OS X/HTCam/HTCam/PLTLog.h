//
//  PLTLog.h
//
//  Created by Davis, Morgan on 1/22/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//
//  ********* VERSION 1.0.1, Jan 30, 2013 *********
//
//  *** Note that if the rest of your project uses ARC, you need to add the "-fno-objc-arc"
//  flag to this file in the "Compile Sources" Build Phase. ***
//

#import <Foundation/Foundation.h>


extern void _PLTDLog( const char *aFile, int aLine, NSString *format, ... );
extern void _PLTFLog( const char *aFile, int aLine, NSString *format, ... );


#define DLog(format,...) _PLTDLog(__FILE__,__LINE__,format,##__VA_ARGS__)
#define FLog(format,...) _PLTFLog(__FILE__,__LINE__,format,##__VA_ARGS__)

