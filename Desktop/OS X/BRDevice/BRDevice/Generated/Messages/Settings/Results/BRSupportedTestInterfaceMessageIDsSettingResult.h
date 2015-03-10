//
//  BRSupportedTestInterfaceMessageIDsSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING_RESULT 0x1011



@interface BRSupportedTestInterfaceMessageIDsSettingResult : BRSettingResult

@property(nonatomic,readonly) NSData * testInterfaceCommandIDs;
@property(nonatomic,readonly) NSData * testInterfaceSettingIDs;
@property(nonatomic,readonly) NSData * testInterfaceEventIDs;


@end
