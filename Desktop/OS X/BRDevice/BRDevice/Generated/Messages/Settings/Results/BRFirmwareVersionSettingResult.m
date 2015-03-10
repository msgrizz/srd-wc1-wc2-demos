//
//  BRFirmwareVersionSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRFirmwareVersionSettingResult.h"
#import "BRMessage_Private.h"


@interface BRFirmwareVersionSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t buildTarget;
@property(nonatomic,assign,readwrite) uint16_t _release;


@end


@implementation BRFirmwareVersionSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FIRMWARE_VERSION_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"buildTarget", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"_release", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRFirmwareVersionSettingResult %p> buildTarget=0x%04X, _release=0x%04X",
            self, self.buildTarget, self._release];
}

@end
