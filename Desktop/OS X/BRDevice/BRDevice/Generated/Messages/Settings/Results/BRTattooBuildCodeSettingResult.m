//
//  BRTattooBuildCodeSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTattooBuildCodeSettingResult.h"
#import "BRMessage_Private.h"


@interface BRTattooBuildCodeSettingResult ()

@property(nonatomic,strong,readwrite) NSData * buildCode;


@end


@implementation BRTattooBuildCodeSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TATTOO_BUILD_CODE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"buildCode", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTattooBuildCodeSettingResult %p> buildCode=%@",
            self, self.buildCode];
}

@end
