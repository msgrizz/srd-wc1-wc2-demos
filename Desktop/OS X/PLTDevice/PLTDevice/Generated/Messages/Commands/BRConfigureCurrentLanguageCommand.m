//
//  BRConfigureCurrentLanguageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureCurrentLanguageCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureCurrentLanguageCommand

#pragma mark - Public

+ (BRConfigureCurrentLanguageCommand *)commandWithLanguageId:(uint16_t)languageId
{
	BRConfigureCurrentLanguageCommand *instance = [[BRConfigureCurrentLanguageCommand alloc] init];
	instance.languageId = languageId;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_CURRENT_LANGUAGE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"languageId", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureCurrentLanguageCommand %p> languageId=0x%04X",
            self, self.languageId];
}

@end
