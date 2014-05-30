//
//  BRProductNameSettingRequest.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRProductNameSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRProductNameSettingRequest

#pragma BRMessage

- (NSData *)payload
{
    NSString *hexString = [NSString stringWithFormat:@"%04X",
                           0x0A00];                     // deckard id
    
    return [NSData dataWithHexString:hexString];
}

@end
