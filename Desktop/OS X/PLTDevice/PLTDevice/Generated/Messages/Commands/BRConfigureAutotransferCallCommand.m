//
//  BRConfigureAutotransferCallCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureAutotransferCallCommand.h"
#import "BRMessage_Private.h"




@implementation BRConfigureAutotransferCallCommand

#pragma mark - Public

+ (BRConfigureAutotransferCallCommand *)commandWithAutoTransferCall:(BOOL)autoTransferCall
{
	BRConfigureAutotransferCallCommand *instance = [[BRConfigureAutotransferCallCommand alloc] init];
	instance.autoTransferCall = autoTransferCall;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_AUTOTRANSFER_CALL;
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
    return [NSString stringWithFormat:@"<BRConfigureAutotransferCallCommand %p> autoTransferCall=%@",
            self, (self.autoTransferCall ? @"YES" : @"NO")];
}

@end
