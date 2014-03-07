//
//  NSData+HexStrings.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "NSData+HexStrings.h"


@implementation NSData (NSData_HexStrings)

+ (NSData *)dataWithHexString:(NSString *)hexString
{
    NSString *str = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *data= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < ([str length] / 2); i++) {
        byte_chars[0] = [str characterAtIndex:i*2];
        byte_chars[1] = [str characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1]; 
    }
    return data;
}

- (NSString *)hexStringWithSpaceEvery:(unsigned int)spaceInterval
{
    const unsigned char* bytes = (const unsigned char*)[self bytes];
    NSUInteger nbBytes = [self length];
    //If spaces is true, insert a space every this many input bytes (twice this many output characters).
    NSUInteger spaceEveryThisManyBytes = spaceInterval;
    NSUInteger strLen = 2*nbBytes + (spaceInterval>0 ? nbBytes/spaceEveryThisManyBytes : 0);
    
    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
    for(NSUInteger i=0; i<nbBytes; ) {
        [hex appendFormat:@"%02X", bytes[i]];
        //We need to increment here so that the every-n-bytes computations are right.
        ++i;
        
        if (spaceInterval>0) {
            if (i % spaceEveryThisManyBytes == 0) [hex appendString:@" "];
        }
    }
    return hex;
}

//- (NSString *)hexStringWithSpaces:(BOOL)spaces
//{
//    const unsigned char* bytes = (const unsigned char*)[self bytes];
//    NSUInteger nbBytes = [self length];
//    //If spaces is true, insert a space every this many input bytes (twice this many output characters).
//    static const NSUInteger spaceEveryThisManyBytes = 1UL;
//    //If spaces is true, insert a line-break instead of a space every this many spaces.
//    static const NSUInteger lineBreakEveryThisManySpaces = 4UL;
//    const NSUInteger lineBreakEveryThisManyBytes = spaceEveryThisManyBytes * lineBreakEveryThisManySpaces;
//    NSUInteger strLen = 2*nbBytes + (spaces ? nbBytes/spaceEveryThisManyBytes : 0);
//    
//    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
//    for(NSUInteger i=0; i<nbBytes; ) {
//        [hex appendFormat:@"%02X", bytes[i]];
//        //We need to increment here so that the every-n-bytes computations are right.
//        ++i;
//        
//        if (spaces) {
//            if (i % lineBreakEveryThisManyBytes == 0) [hex appendString:@"\n"];
//            else if (i % spaceEveryThisManyBytes == 0) [hex appendString:@" "];
//        }
//    }
//    return hex;
//}

@end
