//
//  BRDeckardVersionSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeckardVersionSettingResult.h"
#import "BRMessage_Private.h"


@interface BRDeckardVersionSettingResult ()

@property(nonatomic,assign,readwrite) BOOL releaseOrDev;
@property(nonatomic,assign,readwrite) uint16_t majorVersion;
@property(nonatomic,assign,readwrite) uint16_t minorVersion;
@property(nonatomic,assign,readwrite) uint16_t maintenanceVersion;


@end


@implementation BRDeckardVersionSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DECKARD_VERSION_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"releaseOrDev", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"majorVersion", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"minorVersion", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"maintenanceVersion", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeckardVersionSettingResult %p> releaseOrDev=%@, majorVersion=0x%04X, minorVersion=0x%04X, maintenanceVersion=0x%04X",
            self, (self.releaseOrDev ? @"YES" : @"NO"), self.majorVersion, self.minorVersion, self.maintenanceVersion];
}

@end
