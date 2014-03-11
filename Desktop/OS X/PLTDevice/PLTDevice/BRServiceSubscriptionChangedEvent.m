//
//  BRServiceSubscriptionChangedEvent.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRServiceSubscriptionChangedEvent.h"


@implementation BRServiceSubscriptionChangedEvent

#pragma mark - Public

- (void)parseData
{
    uint16_t serviceID;
    [[self.data subdataWithRange:NSMakeRange(8, sizeof(uint16_t))] getBytes:&serviceID length:sizeof(uint16_t)];
    self.serviceID = ntohs(serviceID);

    uint16_t characteristicID;
    [[self.data subdataWithRange:NSMakeRange(10, sizeof(uint16_t))] getBytes:&characteristicID length:sizeof(uint16_t)];
    self.characteristicID = ntohs(characteristicID);
    
    uint16_t mode;
    [[self.data subdataWithRange:NSMakeRange(12, sizeof(uint16_t))] getBytes:&mode length:sizeof(uint16_t)];
    self.mode = ntohs(mode);
    
    uint16_t period;
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint16_t))] getBytes:&period length:sizeof(uint16_t)];
    self.period = ntohs(period);
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRServiceSubscriptionChangedEvent %p> serviceID=0x%04X, characteristicID=0x%04X, mode=%d, period=%d",
            self, self.serviceID, self.characteristicID, self.mode, self.period];
}

@end
