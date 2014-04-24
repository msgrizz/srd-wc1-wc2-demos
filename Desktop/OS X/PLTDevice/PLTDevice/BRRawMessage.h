//
//  BRRawMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 4/1/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


@interface BRRawMessage : BRMessage

+ (BRRawMessage *)messageWithData:(NSData *)data;

@property(nonatomic,strong,readwrite)   NSData  *data;

@end
