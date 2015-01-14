//
//  BRLEDStatusGenericCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_LED_STATUS_GENERIC 0x0E07



@interface BRLEDStatusGenericCommand : BRCommand

+ (BRLEDStatusGenericCommand *)commandWithID:(NSData *)iD color:(NSData *)color state:(NSData *)state;

@property(nonatomic,strong) NSData * iD;
@property(nonatomic,strong) NSData * color;
@property(nonatomic,strong) NSData * state;


@end
