//
//  BRHalGenericSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_HAL_GENERIC_SETTING_REQUEST 0x1106



@interface BRHalGenericSettingRequest : BRSettingRequest

+ (BRHalGenericSettingRequest *)requestWithHalGeneric:(NSData *)halGeneric;

@property(nonatomic,strong) NSData * halGeneric;


@end
