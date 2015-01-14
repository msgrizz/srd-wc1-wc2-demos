//
//  BRPartNumberCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_PART_NUMBER 0x0A05



@interface BRPartNumberCommand : BRCommand

+ (BRPartNumberCommand *)commandWithPartNumber:(uint32_t)partNumber;

@property(nonatomic,assign) uint32_t partNumber;


@end
