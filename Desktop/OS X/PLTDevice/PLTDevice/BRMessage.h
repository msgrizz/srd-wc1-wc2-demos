//
//  BRMesage.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    BRMessageTypeHostProtocolVersion = 0x1,
    BRMessageTypeGetSetting = 0x2,
    BRMessageTypeSettingResultSuccess = 0x3,
    BRMessageTypeSettingResultException = 0x4,
    BRMessageTypeCommand = 0x5,
    BRMessageTypeCommandResultSuccess = 0x6,
    BRMessageTypeCommandResultException = 0x7,
    BRMessageTypeDeviceProtocolVersion = 0x8,
    BRMessageTypeMetadata = 0x9,
    BRMessageTypeEvent = 0xA,
    BRMessageTypeCloseSession = 0xB,
    BRMessageTypeProtocolVersionRejection = 0xC,
    BRMessageTypeConnectionChangeEvent = 0xD
} BRMessageType;


@interface BRMessage : NSObject

@property(nonatomic,assign)     short   identifier;
@property(nonatomic,readonly)   NSData  *data;

@end
