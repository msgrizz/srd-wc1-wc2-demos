//
//  BRCommandRequest.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROutgoingMessage.h"


@interface BRSettingRequest : BROutgoingMessage

+ (BRSettingRequest *)request;

@end
