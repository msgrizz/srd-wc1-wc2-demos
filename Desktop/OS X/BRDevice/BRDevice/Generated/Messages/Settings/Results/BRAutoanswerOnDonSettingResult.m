//
//  BRAutoanswerOnDonSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAutoanswerOnDonSettingResult.h"
#import "BRMessage_Private.h"


@interface BRAutoanswerOnDonSettingResult ()

@property(nonatomic,assign,readwrite) BOOL answerOnDon;


@end


@implementation BRAutoanswerOnDonSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUTOANSWER_ON_DON_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"answerOnDon", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAutoanswerOnDonSettingResult %p> answerOnDon=%@",
            self, (self.answerOnDon ? @"YES" : @"NO")];
}

@end
