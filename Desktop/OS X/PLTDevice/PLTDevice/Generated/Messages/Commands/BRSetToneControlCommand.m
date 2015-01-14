//
//  BRSetToneControlCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetToneControlCommand.h"
#import "BRMessage_Private.h"


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
