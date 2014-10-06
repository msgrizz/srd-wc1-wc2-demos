//
//  BRSetFeatureLockCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_FEATURE_LOCK 0x0F12



@interface BRSetFeatureLockCommand : BRCommand

+ (BRSetFeatureLockCommand *)commandWithCommands:(NSData *)commands;

@property(nonatomic,strong) NSData * commands;


@end
