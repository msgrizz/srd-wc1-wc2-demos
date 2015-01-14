//
//  BRTattooSerialNumberCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TATTOO_SERIAL_NUMBER 0x0A01



@interface BRTattooSerialNumberCommand : BRCommand

+ (BRTattooSerialNumberCommand *)commandWithSerialNumber:(NSData *)serialNumber;

@property(nonatomic,strong) NSData * serialNumber;


@end
