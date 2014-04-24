//
//  BRCloseSessionMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 4/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


@interface BRCloseSessionMessage : BRMessage

+ (BRCloseSessionMessage *)messageWithAddress:(uint32_t)address;

@property(nonatomic,assign) uint32_t   address;

@end
