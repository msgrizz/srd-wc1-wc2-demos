//
//  BRWearingStateSettingRequest.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRWearingStateSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRWearingStateSettingRequest

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 00 00 00 0%1X %04X",
                           6,                       // length
                           BRMessageTypeSettingRequest, // message type
                           0x0202];                 // deckard id
    return [NSData dataWithHexString:hexString];
}

@end
