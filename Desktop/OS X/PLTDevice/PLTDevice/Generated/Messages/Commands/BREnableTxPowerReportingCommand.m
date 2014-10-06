//
//  BREnableTxPowerReportingCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREnableTxPowerReportingCommand.h"
#import "BRMessage_Private.h"




@implementation BREnableTxPowerReportingCommand

#pragma mark - Public

+ (BREnableTxPowerReportingCommand *)commandWithConnectionId:(uint8_t)connectionId enable:(BOOL)enable
{
	BREnableTxPowerReportingCommand *instance = [[BREnableTxPowerReportingCommand alloc] init];
	instance.connectionId = connectionId;
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ENABLE_TXPOWER_REPORTING;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionId", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BREnableTxPowerReportingCommand %p> connectionId=0x%02X, enable=%@",
            self, self.connectionId, (self.enable ? @"YES" : @"NO")];
}

@end
