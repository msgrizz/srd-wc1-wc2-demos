//
//  BRConfigureCallerAnnouncementCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_CALLER_ANNOUNCEMENT 0x0804

extern const uint8_t ConfigureCallerAnnouncementCommand_Value_DoNotAnnounceCallers;
extern const uint8_t ConfigureCallerAnnouncementCommand_Value_AnnounceAllCallers;


@interface BRConfigureCallerAnnouncementCommand : BRCommand

+ (BRConfigureCallerAnnouncementCommand *)commandWithValue:(uint8_t)value;

@property(nonatomic,assign) uint8_t value;


@end
