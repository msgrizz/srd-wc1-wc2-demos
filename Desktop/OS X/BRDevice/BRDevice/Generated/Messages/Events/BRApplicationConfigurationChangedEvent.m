//
//  BRApplicationConfigurationChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRApplicationConfigurationChangedEvent.h"
#import "BRMessage_Private.h"


@interface BRApplicationConfigurationChangedEvent ()

@property(nonatomic,assign,readwrite) uint16_t featureID;
@property(nonatomic,assign,readwrite) uint16_t characteristic;
@property(nonatomic,strong,readwrite) NSData * configurationData;


@end


@implementation BRApplicationConfigurationChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_APPLICATION_CONFIGURATION_CHANGED_EVENT;
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
    return [NSString stringWithFormat:@"<BRApplicationConfigurationChangedEvent %p> featureID=0x%04X, characteristic=0x%04X, configurationData=%@",
            self, self.featureID, self.characteristic, self.configurationData];
}

@end
