//
//  NSData+Hash.h
//  Shaaaaa
//
//  Created by Morgan Davis on 6/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (Hash)

- (NSData *)MD5Data;
- (NSString *)MD5HexString;
- (NSData *)SHA1Data;
- (NSString *)SHA1HexString;

@end
