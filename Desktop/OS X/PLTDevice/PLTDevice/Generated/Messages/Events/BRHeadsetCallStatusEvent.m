//
//  BRHeadsetCallStatusEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHeadsetCallStatusEvent.h"
#import "BRMessage_Private.h"


@interface BRHeadsetCallStatusEvent ()

@property(nonatomic,assign,readwrite) uint16_t numberOfDevices;
@property(nonatomic,assign,readwrite) uint8_t connectionId;
@property(nonatomic,assign,readwrite) uint8_t state;
@property(nonatomic,strong,readwrite) NSString * number;
@property(nonatomic,strong,readwrite) NSString * name;


@end


@implementation BRHeadsetCallStatusEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HEADSET_CALL_STATUS_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"numberOfDevices", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"state", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"number", @"type": @(BRPayloadItemTypeString)},
			@{@"name": @"name", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHeadsetCallStatusEvent %p> numberOfDevices=0x%04X, connectionId=0x%02X, state=0x%02X, number=%@, name=%@",
            self, self.numberOfDevices, self.connectionId, self.state, self.number, self.name];
}

@end
