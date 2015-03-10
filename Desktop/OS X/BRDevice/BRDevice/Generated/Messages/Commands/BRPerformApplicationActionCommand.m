//
//  BRPerformApplicationActionCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRPerformApplicationActionCommand.h"
#import "BRMessage_Private.h"


@implementation BRPerformApplicationActionCommand

#pragma mark - Public

+ (BRPerformApplicationActionCommand *)commandWithApplicationID:(uint16_t)applicationID action:(uint16_t)action operatingData:(NSData *)operatingData
{
	BRPerformApplicationActionCommand *instance = [[BRPerformApplicationActionCommand alloc] init];
	instance.applicationID = applicationID;
	instance.action = action;
	instance.operatingData = operatingData;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PERFORM_APPLICATION_ACTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"applicationID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"action", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"operatingData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPerformApplicationActionCommand %p> applicationID=0x%04X, action=0x%04X, operatingData=%@",
            self, self.applicationID, self.action, self.operatingData];
}

@end
