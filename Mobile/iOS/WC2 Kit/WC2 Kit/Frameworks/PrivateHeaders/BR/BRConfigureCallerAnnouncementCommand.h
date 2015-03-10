//
//  BRConfigureCallerAnnouncementCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_CALLER_ANNOUNCEMENT 0x0804

#define BRDefinedValue_ConfigureCallerAnnouncementCommand_Value_DoNotAnnounceCallers 0x00
#define BRDefinedValue_ConfigureCallerAnnouncementCommand_Value_AnnounceAllCallers 0xFF


@interface BRConfigureCallerAnnouncementCommand : BRCommand

+ (BRConfigureCallerAnnouncementCommand *)commandWithValue:(uint8_t)value;

@property(nonatomic,assign) uint8_t value;


@end
