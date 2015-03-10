//
//  BRSetDefaultOutboundInterfaceCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetDefaultOutboundInterfaceCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetDefaultOutboundInterfaceCommand

#pragma mark - Public

+ (BRSetDefaultOutboundInterfaceCommand *)commandWithInterfaceType:(uint8_t)interfaceType
{
	BRSetDefaultOutboundInterfaceCommand *instance = [[BRSetDefaultOutboundInterfaceCommand alloc] init];
	instance.interfaceType = interfaceType;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_DEFAULT_OUTBOUND_INTERFACE;
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
    return [NSString stringWithFormat:@"<BRSetDefaultOutboundInterfaceCommand %p> interfaceType=0x%02X",
            self, self.interfaceType];
}

@end
