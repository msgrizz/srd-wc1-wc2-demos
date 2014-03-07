//
//  BREvent.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@implementation BREvent

#pragma mark - Private

- (id)initWithData:(NSData *)data
{
    self = [super init];
    self.data = data;
    [self parseData];
    return self;
}

- (void)parseData
{
    
}

@end
