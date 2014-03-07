//
//  BREvent.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BREvent : NSObject

+ (BREvent *)eventWithData:(NSData *)data;
- (id)initWithData:(NSData *)data;
- (void)parseData;

@property(nonatomic,strong) NSData *data;

@end
