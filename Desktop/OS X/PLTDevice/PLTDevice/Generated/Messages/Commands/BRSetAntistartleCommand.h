//
//  BRSetAntistartleCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ANTISTARTLE 0x0F0A



@interface BRSetAntistartleCommand : BRCommand

+ (BRSetAntistartleCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
