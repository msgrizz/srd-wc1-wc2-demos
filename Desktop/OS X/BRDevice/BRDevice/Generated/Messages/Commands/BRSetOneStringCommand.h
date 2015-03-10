//
//  BRSetOneStringCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_STRING 0x0055



@interface BRSetOneStringCommand : BRCommand

+ (BRSetOneStringCommand *)commandWithValue:(NSString *)value;

@property(nonatomic,strong) NSString * value;


@end
