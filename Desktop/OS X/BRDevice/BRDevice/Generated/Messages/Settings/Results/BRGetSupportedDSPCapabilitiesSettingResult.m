//
//  BRGetSupportedDSPCapabilitiesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGetSupportedDSPCapabilitiesSettingResult.h"
#import "BRMessage_Private.h"


@interface BRGetSupportedDSPCapabilitiesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * supportedAndActive;


@end


@implementation BRGetSupportedDSPCapabilitiesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_SUPPORTED_DSP_CAPABILITIES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"supportedAndActive", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetSupportedDSPCapabilitiesSettingResult %p> supportedAndActive=%@",
            self, self.supportedAndActive];
}

@end
