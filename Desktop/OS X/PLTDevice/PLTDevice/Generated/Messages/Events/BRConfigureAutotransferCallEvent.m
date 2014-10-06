//
//  BRConfigureAutotransferCallEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureAutotransferCallEvent.h"
#import "BRMessage_Private.h"




@interface BRConfigureAutotransferCallEvent ()

@property(nonatomic,assign,readwrite) BOOL autoTransferCall;


@end


@implementation BRConfigureAutotransferCallEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_AUTOTRANSFER_CALL_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoTransferCall", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureAutotransferCallEvent %p> autoTransferCall=%@",
            self, (self.autoTransferCall ? @"YES" : @"NO")];
}

@end
