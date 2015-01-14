//
//  BRInvalidCharacteristicsOrOpcodesException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_CHARACTERISTICS_OR_OPCODES_EXCEPTION 0xFF91



@interface BRInvalidCharacteristicsOrOpcodesException : BRException

@property(nonatomic,readonly) NSData * characteristicsOrOpcodes;


@end
