//
//  NSArray+PrettyPrint.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/10/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "NSArray+PrettyPrint.h"


@implementation NSArray (PrettyPrint)

- (NSString *)hexDescriptionFromShortIntegerArray
{
    NSMutableString *str = [@"{ " mutableCopy];
    for (int i = 0; i<[self count]; i++) {
        NSNumber *numNum = self[i];
        uint16_t num = [numNum unsignedShortValue];
        if (i==[self count]-1) { // at the end
            [str appendFormat:@"0x%04X }", num];
        }
        else {
            [str appendFormat:@"0x%04X, ", num];
        }
    }
    return str;
}

@end
