//
//  BRSubscribeToSignalStrengthCommand.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSubscribeToSignalStrengthCommand.h"
#import "NSData+HexStrings.h"


@interface BRSubscribeToSignalStrengthCommand ()

@property(nonatomic,assign,readwrite) BOOL subscribe;

@end


@implementation BRSubscribeToSignalStrengthCommand

+ (BRSubscribeToSignalStrengthCommand *)commandWithSubscription:(BOOL)subscribe
{
    BRSubscribeToSignalStrengthCommand *command = [[BRSubscribeToSignalStrengthCommand alloc] init];
    command.subscribe = subscribe;
    return command;
}

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 00 00 00 0%01X %04X %02X %02X %02X %02X %02X %02X %02X %02X %02X %04X",
                           0x11,                    // length
                           BRMessageTypeCommand,    // message type
                           0x0800,                  // deckard id
                           2,                       // connectionID
                           (int)self.subscribe,     // enabled?
                           0,                       // don only
                           0,                       // trend
                           0,                       // rssi audio
                           0,                       // near/far audio
                           0,                       // near/far audio to base (?)
                           1,                       // sensitivity
                           70,                      // near threshold
                           15];                     // timeout
                           
    return [NSData dataWithHexString:hexString];
}

@end
