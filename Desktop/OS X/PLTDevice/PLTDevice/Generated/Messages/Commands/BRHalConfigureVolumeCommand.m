//
//  BRHalConfigureVolumeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHalConfigureVolumeCommand.h"
#import "BRMessage_Private.h"




@implementation BRHalConfigureVolumeCommand

#pragma mark - Public

+ (BRHalConfigureVolumeCommand *)commandWithScenario:(uint16_t)scenario volumes:(NSData *)volumes
{
	BRHalConfigureVolumeCommand *instance = [[BRHalConfigureVolumeCommand alloc] init];
	instance.scenario = scenario;
	instance.volumes = volumes;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CONFIGURE_VOLUME;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"scenario", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"volumes", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHalConfigureVolumeCommand %p> scenario=0x%04X, volumes=%@",
            self, self.scenario, self.volumes];
}

@end
