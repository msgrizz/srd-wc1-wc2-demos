//
//  BRHostVersionNegotiateCommand.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/10/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


@interface BRHostVersionNegotiateCommand : BRMessage

+ (BRHostVersionNegotiateCommand *)commandWithAddress:(uint32_t)address;

@property(nonatomic,assign) uint32_t   address;

@end
