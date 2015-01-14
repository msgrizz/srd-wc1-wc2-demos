//
//  BRExtendedCallStatusChangeEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRExtendedCallStatusChangeEvent.h"
#import "BRMessage_Private.h"


@interface BRExtendedCallStatusChangeEvent ()

@property(nonatomic,assign,readwrite) uint8_t state;
@property(nonatomic,strong,readwrite) NSString * number;
@property(nonatomic,strong,readwrite) NSString * name;


@end


@implementation BRExtendedCallStatusChangeEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_EXTENDED_CALL_STATUS_CHANGE_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"state", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"number", @"type": @(BRPayloadItemTypeString)},
			@{@"name": @"name", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRExtendedCallStatusChangeEvent %p> state=0x%02X, number=%@, name=%@",
            self, self.state, self.number, self.name];
}

@end
