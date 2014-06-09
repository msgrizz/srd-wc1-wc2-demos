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
@property(nonatomic,assign,readwrite) int conncetionID;

@end


@implementation BRSubscribeToSignalStrengthCommand

+ (BRSubscribeToSignalStrengthCommand *)commandWithSubscription:(BOOL)subscribe connectionID:(int)conncetionID;
{
    BRSubscribeToSignalStrengthCommand *command = [[BRSubscribeToSignalStrengthCommand alloc] init];
    command.subscribe = subscribe;
	command.conncetionID = conncetionID;
    return command;
}

#pragma BRMessage

- (NSData *)payload;
{
    NSString *hexString = [NSString stringWithFormat:@"%04X %02X %02X %02X %02X %02X %02X %02X %02X %02X %04X",
                           0x0800,                  // deckard id
                           self.conncetionID,		// connectionID
                           (int)self.subscribe,     // enabled?
                           0,                       // don only
                           0,                       // trend
                           0,                       // rssi audio
                           0,                       // near/far audio
                           0,                       // near/far audio to base (?)
                           0,                       // sensitivity (5)
                           71,                      // near threshold
						   // this is about 45 days of signal strength monitoring.
						   // if this SDK is ever adapted to be used for enterprise solutions, this limitation will need to be addressed.
                           UINT16_MAX];             // timeout
	
    return [NSData dataWithHexString:hexString];
}

@end
