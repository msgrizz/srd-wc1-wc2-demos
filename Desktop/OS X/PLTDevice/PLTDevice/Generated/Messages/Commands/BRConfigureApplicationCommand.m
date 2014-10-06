//
//  BRConfigureApplicationCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureApplicationCommand.h"
#import "BRMessage_Private.h"


const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_DisplayReadout = 0x0000;
const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_Units = 0x0001;
const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_LockOnPowerup = 0x0002;
const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_LockOnDoff = 0x0003;
const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_EnableButtonLock = 0x0004;
const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_EnablePanicSequence = 0x0005;
const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_DateAndTime = 0x0006;


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
