//
//  NSData+HexString.h
//  Shaaaaa
//
//  Created by Morgan Davis on 6/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (HexString)

+ (NSData *)dataWithHexString:(NSString *)hexString;
- (NSString *)hexString;

@end
