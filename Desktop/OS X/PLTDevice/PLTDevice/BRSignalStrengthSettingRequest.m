//
//  BRSignalStrengthSettingRequest.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSignalStrengthSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRSignalStrengthSettingRequest

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 00 00 00 0%1X %04X %02X",
                           7,                       // length
                           BRMessageTypeSettingRequest, // message type
                           0x0800,                  // deckard id
                           0x02];                   // connection id
    
    return [NSData dataWithHexString:hexString];
}

@end
