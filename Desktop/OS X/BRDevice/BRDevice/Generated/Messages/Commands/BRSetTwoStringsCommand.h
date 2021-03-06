//
//  BRSetTwoStringsCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TWO_STRINGS 0x0061



@interface BRSetTwoStringsCommand : BRCommand

+ (BRSetTwoStringsCommand *)commandWithFirstValue:(NSString *)firstValue secondValue:(NSString *)secondValue;

@property(nonatomic,strong) NSString * firstValue;
@property(nonatomic,strong) NSString * secondValue;


@end
