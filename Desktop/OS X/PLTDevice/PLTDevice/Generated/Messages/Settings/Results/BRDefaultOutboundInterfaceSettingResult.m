//
//  BRDefaultOutboundInterfaceSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDefaultOutboundInterfaceSettingResult.h"
#import "BRMessage_Private.h"




@interface BRDefaultOutboundInterfaceSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t interfaceType;


@end


@implementation BRDefaultOutboundInterfaceSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DEFAULT_OUTBOUND_INTERFACE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"interfaceType", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDefaultOutboundInterfaceSettingResult %p> interfaceType=0x%02X",
            self, self.interfaceType];
}

@end
