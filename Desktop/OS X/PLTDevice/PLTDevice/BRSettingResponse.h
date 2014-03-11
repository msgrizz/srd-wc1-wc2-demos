//
//  BRCommandResponse.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


typedef enum {
    BRSettingResponseIDWearingState =           0x0202,
    BRSettingResponseIDSignalStrength =         0x0800,
    BRSettingResponseIDDeviceInfo =             0xFF18,
    BRSettingResponseIDSeaviceData =            0xFF13
} BRSettingResponseID;


@interface BRSettingResponse : BRMessage {
    
    NSData      *_data;
}

+ (BRSettingResponse *)settingResponseWithData:(NSData *)data;
- (id)initWithData:(NSData *)data;
- (void)parseData;

@end
