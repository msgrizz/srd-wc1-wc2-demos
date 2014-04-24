//
//  BRCalibratePedometerServiceCommand.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCalibratePedometerServiceCommand.h"
#import "NSData+HexStrings.h"
#import "BRSubscribeToServiceCommand.h"


@implementation BRCalibratePedometerServiceCommand

#pragma mark - Public

+ (BRCalibratePedometerServiceCommand *)command
{
    BRCalibratePedometerServiceCommand *command = [[BRCalibratePedometerServiceCommand alloc] init];
    return command;
}

#pragma mark - BRMessage

- (NSData *)data
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 50 00 00 0%1X %04X %04X %04X %04X %02X",
                           0xD,                     // length
                           BRMessageTypeCommand,    // message type
                           0xFF01,                  // deckard id
                           BRServiceIDPedometer,    // serviceID
                           0x0000,                  // characteristic
                           0x0001,                  // BYTE_ARRAY size
                           0x01];                   // reset counter
    
    return [NSData dataWithHexString:hexString];
}

@end
