//
//  BRMakeCallCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_MAKE_CALL 0x0E0C



@interface BRMakeCallCommand : BRCommand

+ (BRMakeCallCommand *)commandWithDigits:(NSString *)digits;

@property(nonatomic,strong) NSString * digits;


@end
