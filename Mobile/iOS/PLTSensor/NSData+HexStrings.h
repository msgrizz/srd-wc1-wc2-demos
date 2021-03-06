//
//  NSData+HexStrings.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (HexStrings)

+ (NSData *)dataWithHexString:(NSString *)hexString;
- (NSString *)hexStringWithSpaceEvery:(unsigned int)spaceInterval;

@end
