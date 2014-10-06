//
//  BRSetPasswordCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetPasswordCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetPasswordCommand

#pragma mark - Public

+ (BRSetPasswordCommand *)commandWithPassword:(NSString *)password
{
	BRSetPasswordCommand *instance = [[BRSetPasswordCommand alloc] init];
	instance.password = password;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_PASSWORD;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"password", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetPasswordCommand %p> password=%@",
            self, self.password];
}

@end
