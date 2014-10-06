//
//  BRSupportedTestInterfaceMessageIDsSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSupportedTestInterfaceMessageIDsSettingResult.h"
#import "BRMessage_Private.h"




@interface BRSupportedTestInterfaceMessageIDsSettingResult ()

@property(nonatomic,strong,readwrite) NSData * testInterfaceCommandIDs;
@property(nonatomic,strong,readwrite) NSData * testInterfaceSettingIDs;
@property(nonatomic,strong,readwrite) NSData * testInterfaceEventIDs;


@end


@implementation BRSupportedTestInterfaceMessageIDsSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"testInterfaceCommandIDs", @"type": @(BRPayloadItemTypeShortArray)},
			@{@"name": @"testInterfaceSettingIDs", @"type": @(BRPayloadItemTypeShortArray)},
			@{@"name": @"testInterfaceEventIDs", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSupportedTestInterfaceMessageIDsSettingResult %p> testInterfaceCommandIDs=%@, testInterfaceSettingIDs=%@, testInterfaceEventIDs=%@",
            self, self.testInterfaceCommandIDs, self.testInterfaceSettingIDs, self.testInterfaceEventIDs];
}

@end
