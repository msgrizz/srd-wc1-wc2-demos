//
//  BRClosePhysicalConnectionCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRClosePhysicalConnectionCommand.h"
#import "BRMessage_Private.h"




@implementation BRClosePhysicalConnectionCommand

#pragma mark - Public

+ (BRClosePhysicalConnectionCommand *)commandWithMilliseconds:(int16_t)milliseconds
{
	BRClosePhysicalConnectionCommand *instance = [[BRClosePhysicalConnectionCommand alloc] init];
	instance.milliseconds = milliseconds;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CLOSE_PHYSICAL_CONNECTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"milliseconds", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRClosePhysicalConnectionCommand %p> milliseconds=0x%04X",
            self, self.milliseconds];
}

@end
