//
//  BRRawDataEventEnableDisableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRawDataEventEnableDisableEvent.h"
#import "BRMessage_Private.h"




@interface BRRawDataEventEnableDisableEvent ()

@property(nonatomic,assign,readwrite) BOOL rawDataEventEnable;


@end


@implementation BRRawDataEventEnableDisableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RAW_DATA_EVENT_ENABLEDISABLE_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"rawDataEventEnable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRRawDataEventEnableDisableEvent %p> rawDataEventEnable=%@",
            self, (self.rawDataEventEnable ? @"YES" : @"NO")];
}

@end
