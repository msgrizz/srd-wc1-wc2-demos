//
//  BRPerformApplicationActionCommand.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPerformApplicationActionCommand.h"
#import "NSData+HexStrings.h"


@implementation BRPerformApplicationActionCommand

+ (BRPerformApplicationActionCommand *)commandWithApplicationID:(uint16_t)applicationID action:(uint16_t)action operatingData:(NSData *)operatingData
{
	BRPerformApplicationActionCommand *command = [[super alloc] init];
	command.applicationID = applicationID;
	command.action = action;
	command.operatingData = operatingData;
	return command;
}

#pragma mark BRMessage

- (NSData *)payload
{
	NSString *hexString = [NSString stringWithFormat:@"%04X %04X %04X %@",
						   0xFF03,                  // deckard id
						   self.applicationID,
						   self.action,             
						   [self.operatingData hexStringWithSpaceEvery:0]];
	
	return [NSData dataWithHexString:hexString];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<BRPerformApplicationActionCommand %p> applicationID=%04X, action=%04X, operatingData=%@",
			self, self.applicationID, self.action, [self.operatingData hexStringWithSpaceEvery:1]];
}

@end
