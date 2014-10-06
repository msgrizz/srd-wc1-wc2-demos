//
//  BRAntistartleSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAntistartleSettingResult.h"
#import "BRMessage_Private.h"




@interface BRAntistartleSettingResult ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRAntistartleSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ANTISTARTLE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAntistartleSettingResult %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
