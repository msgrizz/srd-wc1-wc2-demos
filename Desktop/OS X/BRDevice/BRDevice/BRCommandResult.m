//
//  BRCommandResult.m
//  BRDevice
//
//  Created by Morgan Davis on 1/13/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommandResult.h"


@implementation BRCommandResult

#pragma mark - Private

- (BRMessageType)type
{
	return BRMessageTypeCommandResultSuccess;
}

@end
