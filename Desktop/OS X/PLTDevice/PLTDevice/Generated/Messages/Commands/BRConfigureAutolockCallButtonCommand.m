//
//  BRConfigureAutolockCallButtonCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureAutolockCallButtonCommand.h"
#import "BRMessage_Private.h"




@implementation BRConfigureAutolockCallButtonCommand

#pragma mark - Public

+ (BRConfigureAutolockCallButtonCommand *)commandWithAutoLockCallButton:(BOOL)autoLockCallButton
{
	BRConfigureAutolockCallButtonCommand *instance = [[BRConfigureAutolockCallButtonCommand alloc] init];
	instance.autoLockCallButton = autoLockCallButton;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_AUTOLOCK_CALL_BUTTON;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoLockCallButton", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureAutolockCallButtonCommand %p> autoLockCallButton=%@",
            self, (self.autoLockCallButton ? @"YES" : @"NO")];
}

@end
