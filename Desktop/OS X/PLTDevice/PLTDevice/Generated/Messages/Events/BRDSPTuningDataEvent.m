//
//  BRDSPTuningDataEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDSPTuningDataEvent.h"
#import "BRMessage_Private.h"


@interface BRDSPTuningDataEvent ()

@property(nonatomic,strong,readwrite) NSData * data;


@end


@implementation BRDSPTuningDataEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DSP_TUNING_DATA_EVENT;
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
    return [NSString stringWithFormat:@"<BRDSPTuningDataEvent %p> data=%@",
            self, self.data];
}

@end
