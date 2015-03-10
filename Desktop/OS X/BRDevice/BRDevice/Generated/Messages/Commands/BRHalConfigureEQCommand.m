//
//  BRHalConfigureEQCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRHalConfigureEQCommand.h"
#import "BRMessage_Private.h"


@implementation BRHalConfigureEQCommand

#pragma mark - Public

+ (BRHalConfigureEQCommand *)commandWithScenario:(uint16_t)scenario numberOfEQs:(uint16_t)numberOfEQs eQId:(uint8_t)eQId eQSettings:(NSData *)eQSettings
{
	BRHalConfigureEQCommand *instance = [[BRHalConfigureEQCommand alloc] init];
	instance.scenario = scenario;
	instance.numberOfEQs = numberOfEQs;
	instance.eQId = eQId;
	instance.eQSettings = eQSettings;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CONFIGURE_EQ;
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
    return [NSString stringWithFormat:@"<BRHalConfigureEQCommand %p> scenario=0x%04X, numberOfEQs=0x%04X, eQId=0x%02X, eQSettings=%@",
            self, self.scenario, self.numberOfEQs, self.eQId, self.eQSettings];
}

@end
