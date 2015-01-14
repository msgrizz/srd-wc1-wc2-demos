//
//  BRAutoanswerOnDonEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAutoanswerOnDonEvent.h"
#import "BRMessage_Private.h"


@interface BRAutoanswerOnDonEvent ()

@property(nonatomic,assign,readwrite) BOOL answerOnDon;


@end


@implementation BRAutoanswerOnDonEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUTOANSWER_ON_DON_EVENT;
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
    return [NSString stringWithFormat:@"<BRAutoanswerOnDonEvent %p> answerOnDon=%@",
            self, (self.answerOnDon ? @"YES" : @"NO")];
}

@end
