//
//  BRQuerySignalStrengthSettingRequest.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQuerySignalStrengthSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRQuerySignalStrengthSettingRequest

#pragma mark - Public

+ (BRSettingRequest *)request
{
    BRQuerySignalStrengthSettingRequest *request = [[BRQuerySignalStrengthSettingRequest alloc] init];
    return request;
}

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 00 00 00 0%1X %04X %02X",
                           7,                       // length
                           BRMessageTypeGetSetting, // message type
                           0x0800,                  // deckard id
                           0x01];                   // connection id
    
    
    return [NSData dataWithHexString:hexString];
}

@end
