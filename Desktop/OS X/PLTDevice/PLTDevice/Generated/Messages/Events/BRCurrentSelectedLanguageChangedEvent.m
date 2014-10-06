//
//  BRCurrentSelectedLanguageChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCurrentSelectedLanguageChangedEvent.h"
#import "BRMessage_Private.h"




@interface BRCurrentSelectedLanguageChangedEvent ()

@property(nonatomic,assign,readwrite) int16_t languageId;


@end


@implementation BRCurrentSelectedLanguageChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CURRENT_SELECTED_LANGUAGE_CHANGED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"languageId", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCurrentSelectedLanguageChangedEvent %p> languageId=0x%04X",
            self, self.languageId];
}

@end
