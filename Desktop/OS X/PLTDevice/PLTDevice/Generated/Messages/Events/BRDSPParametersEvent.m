//
//  BRDSPParametersEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDSPParametersEvent.h"
#import "BRMessage_Private.h"


@interface BRDSPParametersEvent ()

@property(nonatomic,assign,readwrite) uint8_t codec;
@property(nonatomic,assign,readwrite) BOOL storeIsVolatile;
@property(nonatomic,assign,readwrite) int16_t parameterIndex;
@property(nonatomic,strong,readwrite) NSData * payload;


@end


@implementation BRDSPParametersEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DSP_PARAMETERS_EVENT;
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
    return [NSString stringWithFormat:@"<BRDSPParametersEvent %p> codec=0x%02X, storeIsVolatile=%@, parameterIndex=0x%04X, payload=%@",
            self, self.codec, (self.storeIsVolatile ? @"YES" : @"NO"), self.parameterIndex, self.payload];
}

@end
