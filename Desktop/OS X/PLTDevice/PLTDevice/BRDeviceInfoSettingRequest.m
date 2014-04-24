//
//  BRDeviceInfoSettingRequest.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceInfoSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRDeviceInfoSettingRequest

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 50 00 00 0%1X %04X",
                           6,                           // length
                           BRMessageTypeSettingRequest, // message type
                           0xFF18];                     // deckard id
    
    return [NSData dataWithHexString:hexString];
}

@end
