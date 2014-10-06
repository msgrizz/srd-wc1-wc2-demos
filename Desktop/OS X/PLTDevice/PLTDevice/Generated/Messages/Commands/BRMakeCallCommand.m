//
//  BRMakeCallCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMakeCallCommand.h"
#import "BRMessage_Private.h"




@implementation BRMakeCallCommand

#pragma mark - Public

+ (BRMakeCallCommand *)commandWithDigits:(NSString *)digits
{
	BRMakeCallCommand *instance = [[BRMakeCallCommand alloc] init];
	instance.digits = digits;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MAKE_CALL;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"digits", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMakeCallCommand %p> digits=%@",
            self, self.digits];
}

@end
