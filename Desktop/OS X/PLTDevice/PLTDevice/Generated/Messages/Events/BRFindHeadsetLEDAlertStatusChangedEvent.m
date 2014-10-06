//
//  BRFindHeadsetLEDAlertStatusChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFindHeadsetLEDAlertStatusChangedEvent.h"
#import "BRMessage_Private.h"




@interface BRFindHeadsetLEDAlertStatusChangedEvent ()

@property(nonatomic,assign,readwrite) BOOL enable;
@property(nonatomic,assign,readwrite) uint8_t timeout;


@end


@implementation BRFindHeadsetLEDAlertStatusChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FIND_HEADSET_LED_ALERT_STATUS_CHANGED_EVENT;
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
    return [NSString stringWithFormat:@"<BRFindHeadsetLEDAlertStatusChangedEvent %p> enable=%@, timeout=0x%02X",
            self, (self.enable ? @"YES" : @"NO"), self.timeout];
}

@end
