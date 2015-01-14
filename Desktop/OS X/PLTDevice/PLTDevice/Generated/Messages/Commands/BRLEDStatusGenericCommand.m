//
//  BRLEDStatusGenericCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLEDStatusGenericCommand.h"
#import "BRMessage_Private.h"


@implementation BRLEDStatusGenericCommand

#pragma mark - Public

+ (BRLEDStatusGenericCommand *)commandWithID:(NSData *)iD color:(NSData *)color state:(NSData *)state
{
	BRLEDStatusGenericCommand *instance = [[BRLEDStatusGenericCommand alloc] init];
	instance.iD = iD;
	instance.color = color;
	instance.state = state;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LED_STATUS_GENERIC;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"iD", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"color", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"state", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRLEDStatusGenericCommand %p> iD=%@, color=%@, state=%@",
            self, self.iD, self.color, self.state];
}

@end
