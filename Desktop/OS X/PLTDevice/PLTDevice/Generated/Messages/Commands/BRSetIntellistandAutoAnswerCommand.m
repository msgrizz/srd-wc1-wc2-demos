//
//  BRSetIntellistandAutoAnswerCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetIntellistandAutoAnswerCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetIntellistandAutoAnswerCommand

#pragma mark - Public

+ (BRSetIntellistandAutoAnswerCommand *)commandWithIntellistand:(BOOL)intellistand
{
	BRSetIntellistandAutoAnswerCommand *instance = [[BRSetIntellistandAutoAnswerCommand alloc] init];
	instance.intellistand = intellistand;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_INTELLISTAND_AUTOANSWER;
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
    return [NSString stringWithFormat:@"<BRSetIntellistandAutoAnswerCommand %p> intellistand=%@",
            self, (self.intellistand ? @"YES" : @"NO")];
}

@end
