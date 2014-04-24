//
//  BRServiceCalibrationSettingRequest.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRServiceCalibrationSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRServiceCalibrationSettingRequest

+ (BRServiceCalibrationSettingRequest *)requestWithServiceID:(uint16_t)serviceID;
{
    BRServiceCalibrationSettingRequest *request = [[BRServiceCalibrationSettingRequest alloc] init];
    request.serviceID = serviceID;
    return request;
}

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 50 00 00 0%1X %04X %04X %04X",
                           10,                      // length
                           BRMessageTypeSettingRequest, // message type
                           0xFF11,                  // deckard id
                           self.serviceID,          
                           0x0000];                 // characteristic
    
    return [NSData dataWithHexString:hexString];
}

@end
