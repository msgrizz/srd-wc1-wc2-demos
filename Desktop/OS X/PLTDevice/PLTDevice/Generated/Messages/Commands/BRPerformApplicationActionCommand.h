//
//  BRPerformApplicationActionCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_PERFORM_APPLICATION_ACTION 0xFF03

extern const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_AudioPrompt;
extern const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_HapticPrompt;
extern const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_Dialog;
extern const uint16_t PerformApplicationActionCommand_ApplicationID_ApplicationID_Lock;
extern const uint16_t PerformApplicationActionCommand_Action_AudioPromptCanned;
extern const uint16_t PerformApplicationActionCommand_Action_AudioPromptTTS;
extern const uint16_t PerformApplicationActionCommand_Action_AudioPromptWav;
extern const uint16_t PerformApplicationActionCommand_Action_HapticPromptCanned;
extern const uint16_t PerformApplicationActionCommand_Action_HapticPromptCustom;
extern const uint16_t PerformApplicationActionCommand_Action_DialogAlert;
extern const uint16_t PerformApplicationActionCommand_Action_DialogYesNo;
extern const uint16_t PerformApplicationActionCommand_Action_DialogEnterOneNumber;
extern const uint16_t PerformApplicationActionCommand_Action_DialogChooseOne;
extern const uint16_t PerformApplicationActionCommand_Action_DialogChooseMulti;
extern const uint16_t PerformApplicationActionCommand_Action_LockConfig;


@interface BRPerformApplicationActionCommand : BRCommand

+ (BRPerformApplicationActionCommand *)commandWithApplicationID:(uint16_t)applicationID action:(uint16_t)action operatingData:(NSData *)operatingData;

@property(nonatomic,assign) uint16_t applicationID;
@property(nonatomic,assign) uint16_t action;
@property(nonatomic,strong) NSData * operatingData;


@end
