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

- (NSData *)payload
{
    NSString *hexString = [NSString stringWithFormat:@"%04X",
                           0xFF18];                     // deckard id
    
    return [NSData dataWithHexString:hexString];
}

@end
