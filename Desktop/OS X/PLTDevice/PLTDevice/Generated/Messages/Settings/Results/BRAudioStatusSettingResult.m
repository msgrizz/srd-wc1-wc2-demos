//
//  BRAudioStatusSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAudioStatusSettingResult.h"
#import "BRMessage_Private.h"




@interface BRAudioStatusSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t codec;
@property(nonatomic,assign,readwrite) uint8_t port;
@property(nonatomic,assign,readwrite) uint8_t speakerGain;
@property(nonatomic,assign,readwrite) uint8_t micGain;


@end


@implementation BRAudioStatusSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUDIO_STATUS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"codec", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"port", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"speakerGain", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"micGain", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAudioStatusSettingResult %p> codec=0x%02X, port=0x%02X, speakerGain=0x%02X, micGain=0x%02X",
            self, self.codec, self.port, self.speakerGain, self.micGain];
}

@end
