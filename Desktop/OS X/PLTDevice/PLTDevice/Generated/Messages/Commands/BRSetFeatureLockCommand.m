//
//  BRSetFeatureLockCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetFeatureLockCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetFeatureLockCommand

#pragma mark - Public

+ (BRSetFeatureLockCommand *)commandWithCommands:(NSData *)commands
{
	BRSetFeatureLockCommand *instance = [[BRSetFeatureLockCommand alloc] init];
	instance.commands = commands;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_FEATURE_LOCK;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"commands", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetFeatureLockCommand %p> commands=%@",
            self, self.commands];
}

@end
