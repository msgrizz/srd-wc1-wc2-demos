//
//  BRTattooSerialNumberCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TATTOO_SERIAL_NUMBER 0x0A01



@interface BRTattooSerialNumberCommand : BRCommand

+ (BRTattooSerialNumberCommand *)commandWithSerialNumber:(NSData *)serialNumber;

@property(nonatomic,strong) NSData * serialNumber;


@end
