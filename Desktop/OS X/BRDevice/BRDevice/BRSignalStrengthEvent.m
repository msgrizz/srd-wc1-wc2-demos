//
//  BRSignalStrengthEvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSignalStrengthEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRSignalStrengthEvent ()

@property(nonatomic,assign,readwrite) uint8_t	connectionID;
@property(nonatomic,assign,readwrite) uint8_t	strength;
@property(nonatomic,assign,readwrite) uint8_t	distance;

@end


@implementation BRSignalStrengthEvent

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
    uint8_t connectionID;
    [[self.data subdataWithRange:NSMakeRange(8, sizeof(uint8_t))] getBytes:&connectionID length:sizeof(uint8_t)];
    self.connectionID = connectionID;
    
    uint8_t strength;
    [[self.data subdataWithRange:NSMakeRange(9, sizeof(uint8_t))] getBytes:&strength length:sizeof(uint8_t)];
    self.strength = strength;
    
    uint8_t distance;
    [[self.data subdataWithRange:NSMakeRange(10, sizeof(uint8_t))] getBytes:&distance length:sizeof(uint8_t)];
    self.distance = distance;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSignalStrengthEvent %p> connectionID=%d, strength=%d, distance=%d",
            self, self.connectionID, self.strength, self.distance];
}

@end
