//
//  BRIntellistandAutoAnswerSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIntellistandAutoAnswerSettingResult.h"
#import "BRMessage_Private.h"




@interface BRIntellistandAutoAnswerSettingResult ()

@property(nonatomic,assign,readwrite) BOOL intellistand;


@end


@implementation BRIntellistandAutoAnswerSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INTELLISTAND_AUTOANSWER_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"intellistand", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRIntellistandAutoAnswerSettingResult %p> intellistand=%@",
            self, (self.intellistand ? @"YES" : @"NO")];
}

@end
