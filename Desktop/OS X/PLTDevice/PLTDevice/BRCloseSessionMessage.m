//
//  BRCloseSessionMessage.m
//  PLTDevice
//
//  Created by Morgan Davis on 4/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCloseSessionMessage.h"
#import "NSData+HexStrings.h"


@implementation BRCloseSessionMessage

#pragma mark - Public

+ (BRCloseSessionMessage *)messageWithAddress:(uint32_t)address
{
    BRCloseSessionMessage *message = [[BRCloseSessionMessage alloc] init];
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
        NSString *hexString = [NSString stringWithFormat:@"1 %03X %07X %01X",
                               0x4,                                 // length
                               self.address,                        // address
                               BRMessageTypeCloseSession            // message type
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
