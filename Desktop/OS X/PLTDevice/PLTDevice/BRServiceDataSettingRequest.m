//
//  BRServiceDataSettingRequest.h
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRServiceDataSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRServiceDataSettingRequest

+ (BRServiceDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID;
{
    BRServiceDataSettingRequest *request = [[BRServiceDataSettingRequest alloc] init];
    request.serviceID = serviceID;
    return request;
}

#pragma BRMessage

- (NSData *)payload
{
    NSString *hexString = [NSString stringWithFormat:@"%04X %04X %04X",
#ifdef OLD_SKEWL_IDS
                           0xFF13,                      // deckard id
#else
						   0xFF0D,
#endif
                           self.serviceID,          
                           0x0000];                     // characteristic
    
    return [NSData dataWithHexString:hexString];
}

@end
