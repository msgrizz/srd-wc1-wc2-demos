//
//  BRConnectionStatusSettingRequest.m
//  PLTDevice
//
//  Created by Morgan Davis on 7/17/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConnectionStatusSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRConnectionStatusSettingRequest

#pragma BRMessage

- (NSData *)payload
{
    NSString *hexString = [NSString stringWithFormat:@"%04X",
                           0x0C00];                     // deckard id
    
    return [NSData dataWithHexString:hexString];
}

@end
