//
//  BRPerformApplicationActionCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_PERFORM_APPLICATION_ACTION 0xFF03

#define BRDefinedValue_PerformApplicationActionCommand_ApplicationID_ApplicationID_AudioPrompt 0x0000
#define BRDefinedValue_PerformApplicationActionCommand_ApplicationID_ApplicationID_HapticPrompt 0x0001
#define BRDefinedValue_PerformApplicationActionCommand_ApplicationID_ApplicationID_Dialog 0x0002
#define BRDefinedValue_PerformApplicationActionCommand_ApplicationID_ApplicationID_Lock 0x0003
#define BRDefinedValue_PerformApplicationActionCommand_Action_AudioPromptCanned 0x0000
#define BRDefinedValue_PerformApplicationActionCommand_Action_AudioPromptTTS 0x0001
#define BRDefinedValue_PerformApplicationActionCommand_Action_AudioPromptWav 0x0002
#define BRDefinedValue_PerformApplicationActionCommand_Action_HapticPromptCanned 0x0000
#define BRDefinedValue_PerformApplicationActionCommand_Action_HapticPromptCustom 0x0001
#define BRDefinedValue_PerformApplicationActionCommand_Action_DialogAlert 0x0000
#define BRDefinedValue_PerformApplicationActionCommand_Action_DialogYesNo 0x0001
#define BRDefinedValue_PerformApplicationActionCommand_Action_DialogEnterOneNumber 0x0002
#define BRDefinedValue_PerformApplicationActionCommand_Action_DialogChooseOne 0x0003
#define BRDefinedValue_PerformApplicationActionCommand_Action_DialogChooseMulti 0x0004
#define BRDefinedValue_PerformApplicationActionCommand_Action_LockConfig 0x0000


@interface BRPerformApplicationActionCommand : BRCommand

+ (BRPerformApplicationActionCommand *)commandWithApplicationID:(uint16_t)applicationID action:(uint16_t)action operatingData:(NSData *)operatingData;

@property(nonatomic,assign) uint16_t applicationID;
@property(nonatomic,assign) uint16_t action;
@property(nonatomic,strong) NSData * operatingData;


@end
