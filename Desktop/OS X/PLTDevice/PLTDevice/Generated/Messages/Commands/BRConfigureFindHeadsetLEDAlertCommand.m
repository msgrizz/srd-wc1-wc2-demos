//
//  BRConfigureFindHeadsetLEDAlertCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureFindHeadsetLEDAlertCommand.h"
#import "BRMessage_Private.h"




@implementation BRConfigureFindHeadsetLEDAlertCommand

#pragma mark - Public

+ (BRConfigureFindHeadsetLEDAlertCommand *)commandWithEnable:(BOOL)enable timeout:(uint8_t)timeout
{
	BRConfigureFindHeadsetLEDAlertCommand *instance = [[BRConfigureFindHeadsetLEDAlertCommand alloc] init];
	instance.enable = enable;
	instance.timeout = timeout;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_FIND_HEADSET_LED_ALERT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"timeout", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureFindHeadsetLEDAlertCommand %p> enable=%@, timeout=0x%02X",
            self, (self.enable ? @"YES" : @"NO"), self.timeout];
}

@end
