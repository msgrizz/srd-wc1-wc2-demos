//
//  BRException.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


typedef enum {
    BRExceptionIDDeviceNotReady =   0xFF94,
    BRExceptionIDIllegalValue =     0x0808
} BRExceptionID;

@interface BRException : BRMessage {
    
    NSData      *_data;
}

+ (BRException *)exceptionWithData:(NSData *)data;

@property(nonatomic,strong) NSData *data;

@end
