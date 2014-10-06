//
//  BRConfigureAutopauseMediaCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_AUTOPAUSE_MEDIA 0x0208



@interface BRConfigureAutopauseMediaCommand : BRCommand

+ (BRConfigureAutopauseMediaCommand *)commandWithAutoPauseMedia:(BOOL)autoPauseMedia;

@property(nonatomic,assign) BOOL autoPauseMedia;


@end
