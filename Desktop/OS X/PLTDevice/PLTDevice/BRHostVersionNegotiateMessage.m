//
//  BRHostVersionNegotiateMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/10/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHostVersionNegotiateMessage.h"
#import "NSData+HexStrings.h"


@implementation BRHostVersionNegotiateMessage

#pragma mark - Public

+ (BRHostVersionNegotiateMessage *)messageWithAddress:(uint32_t)address
{
    BRHostVersionNegotiateMessage *message = [[BRHostVersionNegotiateMessage alloc] init];
    message.address = address;
    return message;
}

#pragma BRMessage

- (NSData *)data
{
    if (self.address > 0xF000000) {
        NSLog(@"Address %08X out of range!", self.address);
    }
    else {
        NSString *hexString = [NSString stringWithFormat:@"1 %03X %07X %01X %02X %02X %02X",
                               0x7,                                 // length
                               self.address,                        // address
                               BRMessageTypeHostProtocolVersion,    // message type
                               0x01,                                // min protocol version
                               0x01,                                // max protocol version
                               0x01                                 // device capibility
                               ];
        
        return [NSData dataWithHexString:hexString];
    }
    
    return nil;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"BRHostVersionNegotiateCommand %p address=%07X",
            self, self.address];
}

@end
