//
//  BRGetDSPParametersSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetDSPParametersSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRGetDSPParametersSettingRequest

#pragma BRSettingRequest

+ (BRGetDSPParametersSettingRequest *)requestWithCodec:(uint8_t)codec storeIsVolatile:(BOOL)storeIsVolatile parameterIndex:(int16_t)parameterIndex
{
	BRGetDSPParametersSettingRequest *instance = [[BRGetDSPParametersSettingRequest alloc] init];
	instance.codec = codec;
	instance.storeIsVolatile = storeIsVolatile;
	instance.parameterIndex = parameterIndex;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_DSP_PARAMETERS_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"codec", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"storeIsVolatile", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"parameterIndex", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetDSPParametersSettingRequest %p> codec=0x%02X, storeIsVolatile=%@, parameterIndex=0x%04X",
            self, self.codec, (self.storeIsVolatile ? @"YES" : @"NO"), self.parameterIndex];
}

@end
