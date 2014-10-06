//
//  BRSetOvertheAirSubscriptionCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOvertheAirSubscriptionCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetOvertheAirSubscriptionCommand

#pragma mark - Public

+ (BRSetOvertheAirSubscriptionCommand *)commandWithOtaEnabled:(BOOL)otaEnabled
{
	BRSetOvertheAirSubscriptionCommand *instance = [[BRSetOvertheAirSubscriptionCommand alloc] init];
	instance.otaEnabled = otaEnabled;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_OVERTHEAIR_SUBSCRIPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"otaEnabled", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOvertheAirSubscriptionCommand %p> otaEnabled=%@",
            self, (self.otaEnabled ? @"YES" : @"NO")];
}

@end
