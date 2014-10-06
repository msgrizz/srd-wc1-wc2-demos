//
//  BRWearingStateSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRWearingStateSettingResult.h"
#import "BRMessage_Private.h"




@interface BRWearingStateSettingResult ()

@property(nonatomic,assign,readwrite) BOOL worn;


@end


@implementation BRWearingStateSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_WEARING_STATE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"worn", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRWearingStateSettingResult %p> worn=%@",
            self, (self.worn ? @"YES" : @"NO")];
}

@end
