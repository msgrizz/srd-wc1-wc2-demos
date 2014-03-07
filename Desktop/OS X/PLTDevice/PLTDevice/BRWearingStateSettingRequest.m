//
//  BRQueryWearingStateSettingRequest.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryWearingStateSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRQueryWearingStateSettingRequest

#pragma mark - Public

+ (BRSettingRequest *)request
{
    BRQueryWearingStateSettingRequest *request = [[BRQueryWearingStateSettingRequest alloc] init];
    return request;
}

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 00 00 00 0%1X %04X",
                           6,                       // length
                           BRMessageTypeGetSetting, // message type
                           0x0202];                 // deckard id
    return [NSData dataWithHexString:hexString];
}

@end
