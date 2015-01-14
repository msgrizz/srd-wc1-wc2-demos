//
//  BRBluetoothDSPSendMessageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_BLUETOOTH_DSP_SEND_MESSAGE 0x0F30



@interface BRBluetoothDSPSendMessageCommand : BRCommand

+ (BRBluetoothDSPSendMessageCommand *)commandWithMessageid:(int16_t)messageid parametera:(int16_t)parametera parameterb:(int16_t)parameterb parameterc:(int16_t)parameterc parameterd:(int16_t)parameterd;

@property(nonatomic,assign) int16_t messageid;
@property(nonatomic,assign) int16_t parametera;
@property(nonatomic,assign) int16_t parameterb;
@property(nonatomic,assign) int16_t parameterc;
@property(nonatomic,assign) int16_t parameterd;


@end
