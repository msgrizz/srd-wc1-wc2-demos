//
//  BRBandwidthsSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBandwidthsSettingResult.h"
#import "BRMessage_Private.h"


@interface BRBandwidthsSettingResult ()

@property(nonatomic,strong,readwrite) NSData * bandwidths;


@end


@implementation BRBandwidthsSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BANDWIDTHS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"bandwidths", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBandwidthsSettingResult %p> bandwidths=%@",
            self, self.bandwidths];
}

@end
