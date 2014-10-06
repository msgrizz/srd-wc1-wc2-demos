//
//  BRConfigureMuteAlertEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureMuteAlertEvent.h"
#import "BRMessage_Private.h"




@interface BRConfigureMuteAlertEvent ()

@property(nonatomic,assign,readwrite) uint8_t mode;
@property(nonatomic,assign,readwrite) uint8_t parameter;


@end


@implementation BRConfigureMuteAlertEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_MUTE_ALERT_EVENT;
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
    return [NSString stringWithFormat:@"<BRConfigureMuteAlertEvent %p> mode=0x%02X, parameter=0x%02X",
            self, self.mode, self.parameter];
}

@end
