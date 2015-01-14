//
//  BRConfigureOLIFeatureCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureOLIFeatureCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureOLIFeatureCommand

#pragma mark - Public

+ (BRConfigureOLIFeatureCommand *)commandWithOLIenable:(uint8_t)oLIenable
{
	BRConfigureOLIFeatureCommand *instance = [[BRConfigureOLIFeatureCommand alloc] init];
	instance.oLIenable = oLIenable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_OLI_FEATURE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"oLIenable", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureOLIFeatureCommand %p> oLIenable=0x%02X",
            self, self.oLIenable];
}

@end
