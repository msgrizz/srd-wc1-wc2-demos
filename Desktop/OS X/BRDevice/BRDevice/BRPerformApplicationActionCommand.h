//
//  BRPerformApplicationActionCommand.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


typedef enum {
	BRApplicationIDAudioPrompt =				0x0000,
	BRApplicationIDHapticPrompt =				0x0001,
	BRApplicationIDDialog =						0x0002,
	BRApplicationIDLock =						0x0003
} BRApplicationID;

typedef enum {
	BRAudioPromptApplicationActionCanned =		0x0000,
	BRAudioPromptApplicationActionTTS =			0x0001,
	BRAudioPromptApplicationActionWAV =			0x0002
} BRAudioPromptApplicationAction;

typedef enum {
	BRHapticPromptApplicationActionCanned =		0x0000,
	BRHapticPromptApplicationActionCustom =		0x0001
} BRHapticPromptApplicationAction;

typedef enum {
	BRDialogApplicationActionTextAlert =		0x0000,
	BRDialogApplicationActionYesNo =			0x0001,
	BRDialogApplicationActionEnterNumber =		0x0002,
	BRDialogApplicationActionChooseOne =		0x0003,
	BRDialogApplicationActionChooseMultiple =	0x0004
} BRDialogApplicationAction;


@interface BRPerformApplicationActionCommand : BRCommand

+ (BRPerformApplicationActionCommand *)commandWithApplicationID:(uint16_t)applicationID action:(uint16_t)action operatingData:(NSData *)operatingData;

@property(nonatomic,assign)		uint16_t	applicationID;
@property(nonatomic,assign)		uint16_t	action;
@property(nonatomic,strong)		NSData		*operatingData;

@end
