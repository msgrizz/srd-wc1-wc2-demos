//
//  BRGenesGUIDSettingRequest.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGenesGUIDSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRGenesGUIDSettingRequest

#pragma BRMessage

- (NSData *)payload
{
    NSString *hexString = [NSString stringWithFormat:@"%04X",
                           0x0A1E];                     // deckard id
    
    return [NSData dataWithHexString:hexString];
}

@end
