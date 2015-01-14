//
//  BRConnectionStatusSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConnectionStatusSettingResult.h"
#import "BRMessage_Private.h"


@interface BRConnectionStatusSettingResult ()

@property(nonatomic,strong,readwrite) NSData * downstreamPortIDs;
@property(nonatomic,strong,readwrite) NSData * connectedPortIDs;
@property(nonatomic,assign,readwrite) uint8_t originatingPortID;


@end


@implementation BRConnectionStatusSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONNECTION_STATUS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"downstreamPortIDs", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"connectedPortIDs", @"type": @(BRPayloadItemTypeByteArray)},
			@{@"name": @"originatingPortID", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConnectionStatusSettingResult %p> downstreamPortIDs=%@, connectedPortIDs=%@, originatingPortID=0x%02X",
            self, self.downstreamPortIDs, self.connectedPortIDs, self.originatingPortID];
}

@end
