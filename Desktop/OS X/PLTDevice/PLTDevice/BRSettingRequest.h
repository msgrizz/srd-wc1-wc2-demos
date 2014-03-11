//
//  BRCommandRequest.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


@interface BRSettingRequest : BRMessage

+ (BRSettingRequest *)request;
- (void)parseData;

@end
