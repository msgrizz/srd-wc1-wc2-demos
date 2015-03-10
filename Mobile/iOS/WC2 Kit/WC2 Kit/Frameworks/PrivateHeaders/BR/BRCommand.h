//
//  BRCommand.h
//  BRDevice
//
//  Created by Morgan Davis on 5/17/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROutgoingMessage.h"


@interface BRCommand : BROutgoingMessage

+ (BRCommand *)command;

@end
