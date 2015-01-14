//
//  BRInvalidCharacteristicsOrOpcodesException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRInvalidCharacteristicsOrOpcodesException.h"
#import "BRMessage_Private.h"


@interface BRInvalidCharacteristicsOrOpcodesException ()

@property(nonatomic,strong,readwrite) NSData * characteristicsOrOpcodes;


@end


@implementation BRInvalidCharacteristicsOrOpcodesException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INVALID_CHARACTERISTICS_OR_OPCODES_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"characteristicsOrOpcodes", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRInvalidCharacteristicsOrOpcodesException %p> characteristicsOrOpcodes=%@",
            self, self.characteristicsOrOpcodes];
}

@end
