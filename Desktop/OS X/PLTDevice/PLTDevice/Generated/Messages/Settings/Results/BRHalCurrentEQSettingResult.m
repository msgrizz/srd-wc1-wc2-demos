//
//  BRHalCurrentEQSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHalCurrentEQSettingResult.h"
#import "BRMessage_Private.h"




@interface BRHalCurrentEQSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t scenario;
@property(nonatomic,assign,readwrite) uint16_t numberOfEQs;
@property(nonatomic,assign,readwrite) uint8_t eQId;
@property(nonatomic,strong,readwrite) NSData * eQSettings;


@end


@implementation BRHalCurrentEQSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CURRENT_EQ_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRHalCurrentEQSettingResult %p> scenario=0x%04X, numberOfEQs=0x%04X, eQId=0x%02X, eQSettings=%@",
            self, self.scenario, self.numberOfEQs, self.eQId, self.eQSettings];
}

@end
