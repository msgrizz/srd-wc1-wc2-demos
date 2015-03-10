//
//  BRDSPTuningMessageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRDSPTuningMessageCommand.h"
#import "BRMessage_Private.h"


@implementation BRDSPTuningMessageCommand

#pragma mark - Public

+ (BRDSPTuningMessageCommand *)commandWithData:(NSData *)data
{
	BRDSPTuningMessageCommand *instance = [[BRDSPTuningMessageCommand alloc] init];
	instance.data = data;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DSP_TUNING_MESSAGE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"data", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDSPTuningMessageCommand %p> data=%@",
            self, self.data];
}

@end
