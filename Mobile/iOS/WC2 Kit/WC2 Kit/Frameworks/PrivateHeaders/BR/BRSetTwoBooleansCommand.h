//
//  BRSetTwoBooleansCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TWO_BOOLEANS 0x0060



@interface BRSetTwoBooleansCommand : BRCommand

+ (BRSetTwoBooleansCommand *)commandWithFirstValue:(BOOL)firstValue secondValue:(BOOL)secondValue;

@property(nonatomic,assign) BOOL firstValue;
@property(nonatomic,assign) BOOL secondValue;


@end
