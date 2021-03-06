//
//  BRSetDefaultOutboundInterfaceEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetDefaultOutboundInterfaceEvent.h"
#import "BRMessage_Private.h"


@interface BRSetDefaultOutboundInterfaceEvent ()

@property(nonatomic,assign,readwrite) uint8_t interfaceType;


@end


@implementation BRSetDefaultOutboundInterfaceEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_DEFAULT_OUTBOUND_INTERFACE_EVENT;
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
    return [NSString stringWithFormat:@"<BRSetDefaultOutboundInterfaceEvent %p> interfaceType=0x%02X",
            self, self.interfaceType];
}

@end
