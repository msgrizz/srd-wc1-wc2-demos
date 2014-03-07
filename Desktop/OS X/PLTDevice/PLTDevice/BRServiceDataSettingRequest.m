//
//  BRQueryServiceDataSettingRequest.m
//  PLTDevice
//
//  Created by Davis, Morgan on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryServiceDataSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRQueryServiceDataSettingRequest

+ (BRQueryServiceDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID;
{
    BRQueryServiceDataSettingRequest *request = [[BRQueryServiceDataSettingRequest alloc] init];
    request.serviceID = serviceID;
    return request;
}

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 50 00 00 0%1X %04X %02X %02X",
                           8,                       // length
                           BRMessageTypeGetSetting, // message type
                           0xFF13,                  // deckard id
                           self.serviceID,          
                           0x00];                   // characteristic
    
    return [NSData dataWithHexString:hexString];
}

@end
