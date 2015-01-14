//
//  BRMakeCallCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_MAKE_CALL 0x0E0C



@interface BRMakeCallCommand : BRCommand

+ (BRMakeCallCommand *)commandWithDigits:(NSString *)digits;

@property(nonatomic,strong) NSString * digits;


@end
