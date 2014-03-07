//
//  BRSubscribeToSignalStrengthCommand.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/25/14.
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
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 00 00 00 0%01X %04X %d %d %d %d %d %d %d %d %d %04X",
                           0xE,                     // length
                           BRMessageTypeCommand,    // message type
                           0xFF0A,                  // deckard id
                           0,                       // connectionID
                           (int)self.subscribe,     // enabled?
                           0,                       // don only
                           0,                       // trend
                           0,                       // rssi audio
                           0,                       // near/far audio
                           0,                       // near/far audio to base (?)
                           1,                       // sensitivity
                           0,                       // near threshold
                           15];                     // timeout
                           
    return [NSData dataWithHexString:hexString];
}

@end
