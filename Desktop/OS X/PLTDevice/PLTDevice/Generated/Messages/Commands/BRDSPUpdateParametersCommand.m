//
//  BRDSPUpdateParametersCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDSPUpdateParametersCommand.h"
#import "BRMessage_Private.h"




@implementation BRDSPUpdateParametersCommand

#pragma mark - Public

+ (BRDSPUpdateParametersCommand *)commandWithCodec:(uint8_t)codec
{
	BRDSPUpdateParametersCommand *instance = [[BRDSPUpdateParametersCommand alloc] init];
	instance.codec = codec;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DSP_UPDATE_PARAMETERS;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"codec", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDSPUpdateParametersCommand %p> codec=0x%02X",
            self, self.codec];
}

@end
