//
//  BRHeadsetCallStatusSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHeadsetCallStatusSettingResult.h"
#import "BRMessage_Private.h"




@interface BRHeadsetCallStatusSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t numberOfDevices;
@property(nonatomic,assign,readwrite) uint8_t connectionId;
@property(nonatomic,assign,readwrite) uint8_t state;
@property(nonatomic,strong,readwrite) NSString * number;


@end


@implementation BRHeadsetCallStatusSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HEADSET_CALL_STATUS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"numberOfDevices", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"state", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"number", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHeadsetCallStatusSettingResult %p> numberOfDevices=0x%04X, connectionId=0x%02X, state=0x%02X, number=%@",
            self, self.numberOfDevices, self.connectionId, self.state, self.number];
}

@end
