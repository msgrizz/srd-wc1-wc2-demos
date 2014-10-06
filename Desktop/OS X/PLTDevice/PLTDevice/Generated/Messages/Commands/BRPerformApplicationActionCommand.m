//
//  BRPerformApplicationActionCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPerformApplicationActionCommand.h"
#import "BRMessage_Private.h"


const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_AudioPrompt = 0x0000;
const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_HapticPrompt = 0x0001;
const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_Dialog = 0x0002;
const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_Lock = 0x0003;
const uint16_t PerformApplicationActionCommand_Action_AudioPromptCanned = 0x0000;
const uint16_t PerformApplicationActionCommand_Action_AudioPromptTTS = 0x0001;
const uint16_t PerformApplicationActionCommand_Action_AudioPromptWav = 0x0002;
const uint16_t PerformApplicationActionCommand_Action_HapticPromptCanned = 0x0000;
const uint16_t PerformApplicationActionCommand_Action_HapticPromptCustom = 0x0001;
const uint16_t PerformApplicationActionCommand_Action_DialogAlert = 0x0000;
const uint16_t PerformApplicationActionCommand_Action_DialogYesNo = 0x0001;
const uint16_t PerformApplicationActionCommand_Action_DialogEnterOneNumber = 0x0002;
const uint16_t PerformApplicationActionCommand_Action_DialogChooseOne = 0x0003;
const uint16_t PerformApplicationActionCommand_Action_DialogChooseMulti = 0x0004;
const uint16_t PerformApplicationActionCommand_Action_LockConfig = 0x0000;


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
