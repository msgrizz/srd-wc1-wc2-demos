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

- (NSData *)payload
{
	NSString *hexString = [NSString stringWithFormat:@"%04X %04X %04X",
#ifdef OLD_SKEWL_IDS
						   0xFF11,                  // deckard id
#else
						   0xFF01,
#endif
                           self.serviceID,          
                           0x0000];                 // characteristic
    
    return [NSData dataWithHexString:hexString];
}

@end
