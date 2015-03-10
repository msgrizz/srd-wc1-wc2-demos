//
//  BRLEDStatusSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRLEDStatusSettingResult.h"
#import "BRMessage_Private.h"


@interface BRLEDStatusSettingResult ()

@property(nonatomic,strong,readwrite) NSData * lEDIndication;


@end


@implementation BRLEDStatusSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LED_STATUS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"lEDIndication", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRLEDStatusSettingResult %p> lEDIndication=%@",
            self, self.lEDIndication];
}

@end
