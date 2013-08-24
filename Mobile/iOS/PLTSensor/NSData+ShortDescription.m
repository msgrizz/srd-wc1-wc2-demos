//
//  NSData+ShortDescription.m
//  GoldenEye
//
//  Created by Morgan Davis on 2/23/12.
//  Copyright (c) 2012 AOptix Technologies. All rights reserved.
//

#import "NSData+ShortDescription.h"

@implementation NSData (ShortDescription)

- (NSString *)description
{
	return [NSString stringWithFormat:@"<NSData: %p length %d>",self,self.length];
}

@end
