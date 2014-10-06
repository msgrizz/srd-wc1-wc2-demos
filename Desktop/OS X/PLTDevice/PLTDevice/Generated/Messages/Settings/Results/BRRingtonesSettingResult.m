//
//  BRRingtonesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRingtonesSettingResult.h"
#import "BRMessage_Private.h"




@interface BRRingtonesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * ringTones;


@end


@implementation BRRingtonesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RINGTONES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"ringTones", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRRingtonesSettingResult %p> ringTones=%@",
            self, self.ringTones];
}

@end
