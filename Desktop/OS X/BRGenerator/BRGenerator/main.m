//
//  main.m
//  PLTBRGenerator
//
//  Created by Morgan Davis on 9/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Generator.h"


int main(int argc, const char * argv[]) {
	@autoreleasepool {
		Generator *generator = [[Generator alloc] init];
		[generator generate];
	}
    return 0;
}
