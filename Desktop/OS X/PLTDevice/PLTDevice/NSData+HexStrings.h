//
//  NSData+HexStrings.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (NSData_HexStrings)

+ (NSData *)dataWithHexString:(NSString *)hexString;
- (NSString *)hexStringWithSpaceEvery:(unsigned int)spaceInterval;

@end
