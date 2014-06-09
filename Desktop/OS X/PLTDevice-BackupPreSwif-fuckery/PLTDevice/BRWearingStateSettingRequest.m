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

- (NSData *)payload
{
    NSString *hexString = [NSString stringWithFormat:@"%04X",
                           0x0202];                 // deckard id
    return [NSData dataWithHexString:hexString];
}

@end
