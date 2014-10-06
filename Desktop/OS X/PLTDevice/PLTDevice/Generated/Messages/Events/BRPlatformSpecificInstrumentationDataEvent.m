//
//  BRPlatformSpecificInstrumentationDataEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPlatformSpecificInstrumentationDataEvent.h"
#import "BRMessage_Private.h"




@interface BRPlatformSpecificInstrumentationDataEvent ()

@property(nonatomic,strong,readwrite) NSData * data;


@end


@implementation BRPlatformSpecificInstrumentationDataEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PLATFORM_SPECIFIC_INSTRUMENTATION_DATA_EVENT;
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
    return [NSString stringWithFormat:@"<BRPlatformSpecificInstrumentationDataEvent %p> data=%@",
            self, self.data];
}

@end
