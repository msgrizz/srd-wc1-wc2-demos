//
//  BRVocalystInfoNumberCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRVocalystInfoNumberCommand.h"
#import "BRMessage_Private.h"


@implementation BRVocalystInfoNumberCommand

#pragma mark - Public

+ (BRVocalystInfoNumberCommand *)commandWithInfoPhoneNumber:(NSString *)infoPhoneNumber
{
	BRVocalystInfoNumberCommand *instance = [[BRVocalystInfoNumberCommand alloc] init];
	instance.infoPhoneNumber = infoPhoneNumber;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOCALYST_INFO_NUMBER;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"infoPhoneNumber", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVocalystInfoNumberCommand %p> infoPhoneNumber=%@",
            self, self.infoPhoneNumber];
}

@end
