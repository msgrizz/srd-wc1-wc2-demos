//
//  BRHalEQChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRHalEQChangedEvent.h"
#import "BRMessage_Private.h"


@interface BRHalEQChangedEvent ()

@property(nonatomic,assign,readwrite) uint16_t scenario;
@property(nonatomic,assign,readwrite) uint16_t numberOfEQs;
@property(nonatomic,assign,readwrite) uint8_t eQId;
@property(nonatomic,strong,readwrite) NSData * eQSettings;


@end


@implementation BRHalEQChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_EQ_CHANGED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"scenario", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"numberOfEQs", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"eQId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"eQSettings", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHalEQChangedEvent %p> scenario=0x%04X, numberOfEQs=0x%04X, eQId=0x%02X, eQSettings=%@",
            self, self.scenario, self.numberOfEQs, self.eQId, self.eQSettings];
}

@end
