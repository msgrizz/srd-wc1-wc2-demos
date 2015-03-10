//
//  BRConfigureApplicationCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureApplicationCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureApplicationCommand

#pragma mark - Public

+ (BRConfigureApplicationCommand *)commandWithFeatureID:(uint16_t)featureID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData
{
	BRConfigureApplicationCommand *instance = [[BRConfigureApplicationCommand alloc] init];
	instance.featureID = featureID;
	instance.characteristic = characteristic;
	instance.configurationData = configurationData;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_APPLICATION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"featureID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"configurationData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureApplicationCommand %p> featureID=0x%04X, characteristic=0x%04X, configurationData=%@",
            self, self.featureID, self.characteristic, self.configurationData];
}

@end
