//
//  BRAutoanswerOnDonCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAutoanswerOnDonCommand.h"
#import "BRMessage_Private.h"


@implementation BRAutoanswerOnDonCommand

#pragma mark - Public

+ (BRAutoanswerOnDonCommand *)commandWithAnswerOnDon:(BOOL)answerOnDon
{
	BRAutoanswerOnDonCommand *instance = [[BRAutoanswerOnDonCommand alloc] init];
	instance.answerOnDon = answerOnDon;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUTOANSWER_ON_DON;
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
    return [NSString stringWithFormat:@"<BRAutoanswerOnDonCommand %p> answerOnDon=%@",
            self, (self.answerOnDon ? @"YES" : @"NO")];
}

@end
