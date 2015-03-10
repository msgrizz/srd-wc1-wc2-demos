//
//  BRSetDSPParametersCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetDSPParametersCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetDSPParametersCommand

#pragma mark - Public

+ (BRSetDSPParametersCommand *)commandWithCodec:(uint8_t)codec storeIsVolatile:(BOOL)storeIsVolatile parameterIndex:(int16_t)parameterIndex payload:(NSData *)payload
{
	BRSetDSPParametersCommand *instance = [[BRSetDSPParametersCommand alloc] init];
	instance.codec = codec;
	instance.storeIsVolatile = storeIsVolatile;
	instance.parameterIndex = parameterIndex;
	instance.payload = payload;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_DSP_PARAMETERS;
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
    return [NSString stringWithFormat:@"<BRSetDSPParametersCommand %p> codec=0x%02X, storeIsVolatile=%@, parameterIndex=0x%04X, payload=%@",
            self, self.codec, (self.storeIsVolatile ? @"YES" : @"NO"), self.parameterIndex, self.payload];
}

@end
