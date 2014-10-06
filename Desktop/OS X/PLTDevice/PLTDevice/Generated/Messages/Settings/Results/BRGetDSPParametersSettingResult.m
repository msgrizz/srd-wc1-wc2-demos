//
//  BRGetDSPParametersSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetDSPParametersSettingResult.h"
#import "BRMessage_Private.h"




@interface BRGetDSPParametersSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t codec;
@property(nonatomic,assign,readwrite) BOOL storeIsVolatile;
@property(nonatomic,assign,readwrite) int16_t parameterIndex;
@property(nonatomic,strong,readwrite) NSData * payload;


@end


@implementation BRGetDSPParametersSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_DSP_PARAMETERS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"codec", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"storeIsVolatile", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"parameterIndex", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"payload", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetDSPParametersSettingResult %p> codec=0x%02X, storeIsVolatile=%@, parameterIndex=0x%04X, payload=%@",
            self, self.codec, (self.storeIsVolatile ? @"YES" : @"NO"), self.parameterIndex, self.payload];
}

@end
