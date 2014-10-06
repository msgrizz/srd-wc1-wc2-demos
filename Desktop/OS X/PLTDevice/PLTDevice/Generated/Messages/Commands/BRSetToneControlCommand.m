//
//  BRSetToneControlCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetToneControlCommand.h"
#import "BRMessage_Private.h"


const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMaxBass = 0;
const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMidBass = 1;
const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMinBass = 2;
const uint8_t SetToneControlCommand_ToneLevel_ToneLevelNoBoost = 3;
const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMinTreble = 4;
const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMidTreble = 5;
const uint8_t SetToneControlCommand_ToneLevel_ToneLevelMaxTreble = 6;


@implementation BRSetToneControlCommand

#pragma mark - Public

+ (BRSetToneControlCommand *)commandWithInterfaceType:(uint8_t)interfaceType toneLevel:(uint8_t)toneLevel
{
	BRSetToneControlCommand *instance = [[BRSetToneControlCommand alloc] init];
	instance.interfaceType = interfaceType;
	instance.toneLevel = toneLevel;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_TONE_CONTROL;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"interfaceType", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"toneLevel", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetToneControlCommand %p> interfaceType=0x%02X, toneLevel=0x%02X",
            self, self.interfaceType, self.toneLevel];
}

@end
