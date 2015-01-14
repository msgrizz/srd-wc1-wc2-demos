//
//  BRConfigureMuteAlertCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureMuteAlertCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureMuteAlertCommand

#pragma mark - Public

+ (BRConfigureMuteAlertCommand *)commandWithMode:(uint8_t)mode parameter:(uint8_t)parameter
{
	BRConfigureMuteAlertCommand *instance = [[BRConfigureMuteAlertCommand alloc] init];
	instance.mode = mode;
	instance.parameter = parameter;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_MUTE_ALERT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"mode", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"parameter", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureMuteAlertCommand %p> mode=0x%02X, parameter=0x%02X",
            self, self.mode, self.parameter];
}

@end
