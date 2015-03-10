//
//  BRAutotransferCallSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAutotransferCallSettingResult.h"
#import "BRMessage_Private.h"


@interface BRAutotransferCallSettingResult ()

@property(nonatomic,assign,readwrite) BOOL autoTransferCall;


@end


@implementation BRAutotransferCallSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUTOTRANSFER_CALL_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoTransferCall", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAutotransferCallSettingResult %p> autoTransferCall=%@",
            self, (self.autoTransferCall ? @"YES" : @"NO")];
}

@end
