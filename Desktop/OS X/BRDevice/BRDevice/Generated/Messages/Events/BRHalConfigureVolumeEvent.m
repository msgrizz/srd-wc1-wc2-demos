//
//  BRHalConfigureVolumeEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRHalConfigureVolumeEvent.h"
#import "BRMessage_Private.h"


@interface BRHalConfigureVolumeEvent ()

@property(nonatomic,assign,readwrite) uint16_t scenario;
@property(nonatomic,strong,readwrite) NSData * volumes;


@end


@implementation BRHalConfigureVolumeEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CONFIGURE_VOLUME_EVENT;
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
    return [NSString stringWithFormat:@"<BRHalConfigureVolumeEvent %p> scenario=0x%04X, volumes=%@",
            self, self.scenario, self.volumes];
}

@end
