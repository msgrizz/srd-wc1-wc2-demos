//
//  BRGyroscopeCalStatus.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGyroscopeCalStatusEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRGyroscopeCalStatusEvent ()

@property(nonatomic,assign,readwrite) BOOL isCalibrated;

@end


@implementation BRGyroscopeCalStatusEvent

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
    uint8_t cal;
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint8_t))] getBytes:&cal length:sizeof(uint8_t)];
    self.isCalibrated = cal;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGyroscopeCalStatus %p> isCalibrated=%@",
            self, (self.isCalibrated ? @"YES" : @"NO")];
}

@end