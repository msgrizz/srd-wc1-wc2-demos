//
//  BRCallStatusSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCallStatusSettingResult.h"
#import "BRMessage_Private.h"


@interface BRCallStatusSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t state;
@property(nonatomic,strong,readwrite) NSString * number;


@end


@implementation BRCallStatusSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CALL_STATUS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"state", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"number", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCallStatusSettingResult %p> state=0x%02X, number=%@",
            self, self.state, self.number];
}

@end
