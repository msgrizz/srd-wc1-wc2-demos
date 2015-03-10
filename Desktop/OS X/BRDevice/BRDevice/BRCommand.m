//
//  BRCommand.m
//  BRDevice
//
//  Created by Morgan Davis on 5/17/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


@implementation BRCommand

#pragma mark - Public

+ (BRMessage *)command
{
	BRCommand *command = [[BRCommand alloc] init];
	return command;
}

#pragma Private

- (BRMessageType)type
{
	return BRMessageTypeCommand;
}

@end
