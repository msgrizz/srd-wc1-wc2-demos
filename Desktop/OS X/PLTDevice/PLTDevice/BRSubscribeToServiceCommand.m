//
//  BRSubscribeToServicesCommandRequest.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSubscribeToServiceCommand.h"
#import "NSData+HexStrings.h"


@implementation BRSubscribeToServiceCommand

#pragma mark - Public

+ (BRSubscribeToServiceCommand *)commandWithServiceID:(uint16_t)serviceID mode:(uint16_t)mode period:(uint16_t)period
{
    BRSubscribeToServiceCommand *command = [[BRSubscribeToServiceCommand alloc] init];
    command.serviceID = serviceID;
    command.mode = mode;
    command.period = period;
    return command;
}

#pragma BRMessage

- (NSData *)data;
{
    NSString *hexString = [NSString stringWithFormat:@"1 %03X 50 00 00 0%01X %04X %04d %04X %04d %04d",
                           0xE,                     // length
                           BRMessageTypeCommand,    // message type
                           0xFF0A,                  // deckard id
                           self.serviceID,
                           0,                       // characteristic
                           self.mode,
                           self.period];
    
    return [NSData dataWithHexString:hexString];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"BRSubscribeToServicesCommandRequest %p serviceID=%02d, mode=%02d, period=%02d",
            self, self.serviceID, self.mode, self.period];
}
            
@end
