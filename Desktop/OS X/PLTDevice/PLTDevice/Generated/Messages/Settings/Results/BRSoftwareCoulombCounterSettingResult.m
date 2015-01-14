//
//  BRSoftwareCoulombCounterSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSoftwareCoulombCounterSettingResult.h"
#import "BRMessage_Private.h"


@interface BRSoftwareCoulombCounterSettingResult ()

@property(nonatomic,strong,readwrite) NSData * datapacket;


@end


@implementation BRSoftwareCoulombCounterSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SOFTWARE_COULOMB_COUNTER_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"datapacket", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSoftwareCoulombCounterSettingResult %p> datapacket=%@",
            self, self.datapacket];
}

@end
