//
//  BRAudioSensingSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAudioSensingSettingResult.h"
#import "BRMessage_Private.h"




@interface BRAudioSensingSettingResult ()

@property(nonatomic,assign,readwrite) BOOL audioSensing;


@end


@implementation BRAudioSensingSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUDIO_SENSING_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"audioSensing", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAudioSensingSettingResult %p> audioSensing=%@",
            self, (self.audioSensing ? @"YES" : @"NO")];
}

@end
